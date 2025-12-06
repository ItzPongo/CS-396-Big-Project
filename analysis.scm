#lang racket
;;; Financial Analysis System in Scheme
;;; Reads finance_data.json and outputs analysis_results.json

(require "json_parser.scm")

;;; MATH

; Compute the sum of all numbers in a list
(define (sum numbers)
  (foldl + 0 numbers))

; Compute the average of all numbers in a list
(define (average numbers)
  (if (null? numbers)
      0
      (/ (sum numbers) (length numbers))))

;;; DATA FILTERING

; Filter transactions by their type of income or expense
(define (filter-by-type transactions target-type)
  (filter (lambda (transaction)
            (string=? (cdr (assoc 'type transaction)) target-type))
          transactions))

; Filter transactions by their category
(define (filter-by-category transactions target-category)
  (filter (lambda (transaction)
            (string=? (cdr (assoc 'category transaction)) target-category))
          transactions))

;;; DATA ACCESS

; Convert any value to a number, returning 0 if conversion fails
(define (safe-number value)
  (cond
    ((number? value) value)
    ((string? value) (or (string->number value) 0))
    (else 0)))

; Look up a key in an association list and return a default if not found
(define (assoc-safe key alist default-value)
  (let ((entry (assoc key alist)))
    (if entry
        (cdr entry)
        default-value)))

; Convert any value to a string
(define (value->string value)
  (cond
    ((string? value) value)
    ((symbol? value) (symbol->string value))
    ((number? value) (number->string value))
    ((boolean? value) (if value "true" "false"))
    ((null? value) "null")
    (else "UNKNOWN")))

;;; TRANSACTION DATA EXTRACTOR

; Extract the amount from a transaction as a number
(define (get-amount transaction)
  (safe-number (cdr (assoc 'amount transaction))))

; Extract the category name from a transaction
(define (get-category transaction)
  (cdr (assoc 'category transaction)))

;;; CALCULATION

; Calculate the total amount from a list of transactions
(define (calculate-total transactions)
  (sum (map get-amount transactions)))

; Group transactions by category and sum their amounts
(define (group-by-category transactions)
  (define (add-to-groups transaction groups)
    (let* ((category (get-category transaction))
           (amount (get-amount transaction))
           (existing (assoc category groups)))
      (if existing
          (cons (cons category (+ (cdr existing) amount))
                (filter (lambda (group) (not (string=? (car group) category))) groups))
          (cons (cons category amount) groups))))
  (foldl add-to-groups '() transactions))

; Calculate spending by category for expense transactions only
(define (calculate-spending-by-category transactions)
  (group-by-category (filter-by-type transactions "expense")))

; Look up spending amount for a category, returning 0 if not found
(define (lookup-spending category-name spending-list)
  (let ((entry (assoc category-name spending-list)))
    (if entry
        (cdr entry)
        0)))

;;; NUMBER FORMATTING

; Convert a number to a string with specified decimal places
(define (num->str number decimal-places)
  (let ((num (safe-number number)))
    (cond
      ((= decimal-places 0) (format "~a" (inexact->exact (round num))))
      ((= decimal-places 1) (format "~a" (/ (round (* num 10)) 10.0)))
      ((= decimal-places 2) (format "~a" (/ (round (* num 100)) 100.0)))
      (else (format "~a" num)))))

;;; BUDGET ANALYSIS

; Calculate budget status for each expense category
(define (calculate-budget-status categories spending-by-category)
  (map (lambda (category)
         (let* ((category-name-raw (assoc-safe 'name category "UNKNOWN"))
                (category-name (value->string category-name-raw))
                (budget-limit (safe-number (assoc-safe 'budget_limit category 0)))
                (spending (safe-number (lookup-spending category-name spending-by-category)))
                (remaining (- budget-limit spending))
                (percentage (if (> budget-limit 0)
                                (* 100 (/ spending budget-limit))
                                0))
                (status-message
                 (cond
                   ((> spending budget-limit)
                    (string-append "OVER BUDGET by $" (num->str (- spending budget-limit) 2)))
                   ((> percentage 80)
                    (string-append "Warning: " (num->str percentage 1) "% of budget used"))
                   (else
                    (string-append "OK - $" (num->str remaining 2) " remaining")))))
           (cons category-name status-message)))
       ; Filter to only include expense categories
       (filter (lambda (category)
                 (let ((type-value (assoc-safe 'type category "")))
                   (string=? (value->string type-value) "expense")))
               categories)))

; Generate a recommendation based on savings rate
(define (generate-recommendation total-income total-expenses net-savings)
  (let ((savings-rate (if (> total-income 0)
                         (* 100 (/ net-savings total-income))
                         0)))
    (cond
      ((< savings-rate 0)
       "WARNING: You are spending more than you earn! Reduce expenses immediately.")
      ((< savings-rate 10)
       "Your savings rate is low. Consider reducing discretionary spending.")
      ((< savings-rate 20)
       "Good progress! Try to increase savings to 20% of income.")
      (else
       "Excellent! You're saving well. Keep up the good work!"))))

;;; MAIN ANALYSIS

; Analyze financial data from input file and write results to output file
(define (analyze-finances input-file output-file)
  (let* ((data (read-json-file input-file))
         (transactions (cdr (assoc 'transactions data)))
         (categories (cdr (assoc 'categories data)))
         
         ; Calculate metrics
         (income-transactions (filter-by-type transactions "income"))
         (expense-transactions (filter-by-type transactions "expense"))
         (total-income (calculate-total income-transactions))
         (total-expenses (calculate-total expense-transactions))
         (net-savings (- total-income total-expenses))
         (spending-by-category (calculate-spending-by-category transactions))
         (budget-status (calculate-budget-status categories spending-by-category))
         (recommendation (generate-recommendation total-income total-expenses net-savings)))
    
    (write-analysis-results output-file
                           total-income
                           total-expenses
                           net-savings
                           spending-by-category
                           budget-status
                           recommendation)))

;;; JSON OUTPUT

; Write analysis results to a JSON file
(define (write-analysis-results filename total-income total-expenses 
                               net-savings spending-by-category
                               budget-status recommendation)
  (call-with-output-file filename
    #:exists 'replace
    (lambda (output-port)
      (display "{\n" output-port)
      (display (string-append "  \"total_income\": " (num->str total-income 2) ",\n") output-port)
      (display (string-append "  \"total_expenses\": " (num->str total-expenses 2) ",\n") output-port)
      (display (string-append "  \"net_savings\": " (num->str net-savings 2) ",\n") output-port)
      
      ; Write category spending amounts
      (for-each (lambda (category-spending)
                  (display (string-append "  \"category_" (car category-spending) "\": " 
                                        (num->str (cdr category-spending) 2) ",\n") output-port))
                spending-by-category)
      
      ; Write budget status for each category
      (for-each (lambda (status)
                  (display (string-append "  \"budget_status_" (car status) "\": \"" (cdr status) "\",\n") output-port))
                budget-status)
      
      ; Write recommendation
      (display (string-append "  \"recommendation\": \"" recommendation "\"\n") output-port)
      (display "}\n" output-port))))

; Execute the analysis
(analyze-finances "finance_data.json" "analysis_results.json")
(display "Analysis complete. Results written to analysis_results.json\n")
(exit 0)