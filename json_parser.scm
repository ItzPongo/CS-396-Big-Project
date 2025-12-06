#lang racket
;;; Simple JSON parser for Scheme
;;; Provides basic JSON reading capabilities

(provide read-json-file)

;;; FILE OPERATIONS

; Read and parse a JSON file into Scheme association lists
(define (read-json-file filename)
  (call-with-input-file filename
    (lambda (input-port)
      (parse-json-value input-port))))

;;; WHITESPACE HANDLING

; Skip all whitespace characters in the input stream
(define (skip-whitespace input-port)
  (let ((character (peek-char input-port)))
    (if (and (not (eof-object? character))
             (char-whitespace? character))
        (begin
          (read-char input-port)
          (skip-whitespace input-port))
        (void))))

;;; JSON VALUE PARSING

; Parse any JSON value
(define (parse-json-value input-port)
  (skip-whitespace input-port)
  (let ((character (peek-char input-port)))
    (cond
      ((eof-object? character) '())
      ((char=? character #\{) (parse-json-object input-port))
      ((char=? character #\[) (parse-json-array input-port))
      ((char=? character #\") (parse-json-string input-port))
      ((or (char-numeric? character) (char=? character #\-)) (parse-json-number input-port))
      ((char=? character #\t) (parse-json-true input-port))
      ((char=? character #\f) (parse-json-false input-port))
      ((char=? character #\n) (parse-json-null input-port))
      (else 
        (error "Unexpected character in JSON" character)))))

;;; OBJECT PARSING

; Parse a JSON object into an association list
(define (parse-json-object input-port)
  ; skip opening '{'
  (read-char input-port)
  (skip-whitespace input-port)
  (if (char=? (peek-char input-port) #\})
      (begin
	    ; skip closing '}'
        (read-char input-port)
        '())
      (let loop ((result '()))
        (skip-whitespace input-port)
        ; Parse key
        (let* ((key (string->symbol (parse-json-string input-port))))
          (skip-whitespace input-port)
          ; Expect colon separator
          (if (not (char=? (read-char input-port) #\:))
              (error "Expected ':' in JSON object")
              #t)
          (skip-whitespace input-port)
          ; Parse value
          (let ((value (parse-json-value input-port)))
            (skip-whitespace input-port)
            (let ((new-result (cons (cons key value) result)))
              (cond
                ((char=? (peek-char input-port) #\})
				 ; skip closing '}'
                 (read-char input-port)
                 (reverse new-result))
                ((char=? (peek-char input-port) #\,)
				 ; skip comma
                 (read-char input-port)
                 (loop new-result))
                (else
                  (error "Expected ',' or '}' in JSON object")))))))))

;;; ARRAY PARSING

; Parse a JSON array into a list
(define (parse-json-array input-port)
  ; skip opening '['
  (read-char input-port)
  (skip-whitespace input-port)
  (if (char=? (peek-char input-port) #\])
      (begin
	    ; skip closing ']'
        (read-char input-port)
        '())
      (let loop ((result '()))
        (skip-whitespace input-port)
        (let ((value (parse-json-value input-port)))
          (skip-whitespace input-port)
          (let ((new-result (cons value result)))
            (cond
              ((char=? (peek-char input-port) #\])
			   ; skip closing ']'
               (read-char input-port)
               (reverse new-result))
              ((char=? (peek-char input-port) #\,)
			   ; skip comma
               (read-char input-port)
               (loop new-result))
              (else
                (error "Expected ',' or ']' in JSON array"))))))))

;;; STRING PARSING

; Parse a JSON string with escape sequences
(define (parse-json-string input-port)
  ; skip opening quote
  (read-char input-port)
  (let loop ((characters '()))
    (let ((current-char (read-char input-port)))
      (cond
        ((eof-object? current-char)
         (error "Unexpected end of file in JSON string"))
        ((char=? current-char #\")
         (list->string (reverse characters)))
        ((char=? current-char #\\)
         (let ((next-char (read-char input-port)))
           (cond
             ((char=? next-char #\") (loop (cons #\" characters)))
             ((char=? next-char #\\) (loop (cons #\\ characters)))
             ((char=? next-char #\/) (loop (cons #\/ characters)))
             ((char=? next-char #\n) (loop (cons #\newline characters)))
             ((char=? next-char #\r) (loop (cons #\return characters)))
             ((char=? next-char #\t) (loop (cons #\tab characters)))
             (else (loop (cons next-char characters))))))
        (else
          (loop (cons current-char characters)))))))

;;; NUMBER PARSING

; Parse a JSON number
(define (parse-json-number input-port)
  (let loop ((characters '()))
    (let ((current-char (peek-char input-port)))
      (cond
        ((or (eof-object? current-char)
             (not (or (char-numeric? current-char)
                     (char=? current-char #\.)
                     (char=? current-char #\-)
                     (char=? current-char #\+)
                     (char=? current-char #\e)
                     (char=? current-char #\E))))
         (string->number (list->string (reverse characters))))
        (else
          (read-char input-port)
          (loop (cons current-char characters)))))))

;;; BOOLEAN AND NULL PARSING

; Parse JSON true literal
(define (parse-json-true input-port)
  (read-char input-port)
  (read-char input-port)
  (read-char input-port)
  (read-char input-port)
  #t)

; Parse JSON false literal
(define (parse-json-false input-port)
  (read-char input-port)
  (read-char input-port)
  (read-char input-port)
  (read-char input-port)
  (read-char input-port)
  #f)

; Parse JSON null literal
(define (parse-json-null input-port)
  (read-char input-port)
  (read-char input-port)
  (read-char input-port)
  (read-char input-port)
  '())