#include "transaction.h"
#include "json_handler.h"
#include <iostream>
#include <iomanip>
#include <cstdlib>
#include <string>

void displayMenu() {
    std::cout << "\n=== Personal Finance Tracker ===\n";
    std::cout << "1. Add Transaction\n";
    std::cout << "2. Add Category\n";
    std::cout << "3. View All Transactions\n";
    std::cout << "4. Run Analysis\n";
    std::cout << "5. Exit\n";
    std::cout << "Choose an option: ";
}

void displayTransactions(const Account& account) {
    std::cout << "\n=== All Transactions ===\n";
    std::cout << std::left << std::setw(12) << "ID" 
              << std::setw(12) << "Date"
              << std::setw(15) << "Category"
              << std::setw(10) << "Amount"
              << std::setw(10) << "Type"
              << "Description\n";
    std::cout << std::string(80, '-') << "\n";
    
    for (const auto& trans : account.getTransactions()) {
        std::cout << std::left << std::setw(12) << trans.getId()
                  << std::setw(12) << trans.getDate()
                  << std::setw(15) << trans.getCategory()
                  << std::right << std::setw(10) << std::fixed << std::setprecision(2) 
                  << trans.getAmount() << std::left
                  << std::setw(10) << trans.getType()
                  << trans.getDescription() << "\n";
    }
    std::cout << "\nCurrent Balance: $" << std::fixed << std::setprecision(2) 
              << account.getBalance() << "\n";
}

void addTransaction(Account& account) {
    std::string id, date, category, description, type;
    double amount;
    
    std::cout << "\n=== Add New Transaction ===\n";
    std::cout << "ID: ";
    std::cin >> id;
    std::cin.ignore();
    
    std::cout << "Date (MM-DD-YYYY): ";
    std::getline(std::cin, date);
    
    std::cout << "Category: ";
    std::getline(std::cin, category);
    
    std::cout << "Amount: $";
    std::cin >> amount;
    std::cin.ignore();
    
    std::cout << "Type (income/expense): ";
    std::getline(std::cin, type);
    
    std::cout << "Description: ";
    std::getline(std::cin, description);
    
    Transaction trans(id, date, category, amount, description, type);
    account.addTransaction(trans);
    
    std::cout << "\nTransaction added successfully!\n";
}

void addCategory(Account& account) {
    std::string name, type;
    double budgetLimit;
    
    std::cout << "\n=== Add New Category ===\n";
    std::cout << "Category Name: ";
    std::cin.ignore();
    std::getline(std::cin, name);
    
    std::cout << "Budget Limit: $";
    std::cin >> budgetLimit;
    std::cin.ignore();
    
    std::cout << "Type (income/expense): ";
    std::getline(std::cin, type);
    
    Category cat(name, budgetLimit, type);
    account.addCategory(cat);
    
    std::cout << "\nCategory added successfully!\n";
}

void runAnalysis(Account& account) {
    std::cout << "\n=== Running Financial Analysis ===\n";
    
    // Write data to JSON
    if (!JSONHandler::writeToJSON("finance_data.json", 
                                  account.getTransactions(),
                                  account.getCategories())) {
        std::cerr << "Error: Failed to write data to JSON file.\n";
        return;
    }
    std::cout << "Data exported to finance_data.json\n";
    
    // Call Scheme script with Windows-compatible command
    std::cout << "Calling Scheme analyzer...\n";
    
    // Use relative path if analysis.scm is in the same directory as the executable
    // Or use full path with proper Windows escaping
    std::string command = "\"Racket\\racket.exe\" analysis.scm";
    
    int result = system(command.c_str());
    
    if (result != 0) {
        std::cerr << "Error: Scheme analysis failed with code " << result << ".\n";
        std::cerr << "Please ensure Racket is installed at: D:\\Racket\\racket.exe\n";
        std::cerr << "And analysis.scm is in the correct directory.\n";
        return;
    }
    
    // Read results
    std::map<std::string, std::string> results;
    if (!JSONHandler::readAnalysisResults("analysis_results.json", results)) {
        std::cerr << "Error: Failed to read analysis results.\n";
        return;
    }
    
    // Display results
    std::cout << "\n=== Analysis Results ===\n";
    std::cout << std::string(60, '=') << "\n";
    
    if (results.find("total_income") != results.end()) {
        std::cout << "Total Income: $" << results["total_income"] << "\n";
    }
    if (results.find("total_expenses") != results.end()) {
        std::cout << "Total Expenses: $" << results["total_expenses"] << "\n";
    }
    if (results.find("net_savings") != results.end()) {
        std::cout << "Net Savings: $" << results["net_savings"] << "\n";
    }
    if (results.find("savings_rate") != results.end()) {
        std::cout << "Savings Rate: " << results["savings_rate"] << "%\n";
    }
    
    std::cout << "\n--- Spending by Category ---\n";
    for (const auto& pair : results) {
        if (pair.first.find("category_") == 0) {
            std::string catName = pair.first.substr(9);
            std::cout << catName << ": $" << pair.second << "\n";
        }
    }
    
    std::cout << "\n--- Budget Status ---\n";
    for (const auto& pair : results) {
        if (pair.first.find("budget_status_") == 0) {
            std::string catName = pair.first.substr(14);
            std::cout << catName << ": " << pair.second << "\n";
        }
    }
    
    if (results.find("recommendation") != results.end()) {
        std::cout << "\n--- Recommendation ---\n";
        std::cout << results["recommendation"] << "\n";
    }
    
    std::cout << std::string(60, '=') << "\n";
}

int main() {
    Account account;
    int choice;
    
    // Add some default categories
    account.addCategory(Category("Groceries", 500.0, "expense"));
    account.addCategory(Category("Entertainment", 200.0, "expense"));
    account.addCategory(Category("Utilities", 300.0, "expense"));
    account.addCategory(Category("Salary", 0.0, "income"));
    
    while (true) {
        displayMenu();
        std::cin >> choice;
        
        switch (choice) {
            case 1:
                addTransaction(account);
                break;
            case 2:
                addCategory(account);
                break;
            case 3:
                displayTransactions(account);
                break;
            case 4:
                runAnalysis(account);
                break;
            case 5:
                std::cout << "Exiting program. Goodbye!\n";
                return 0;
            default:
                std::cout << "Invalid option. Please try again.\n";
        }
    }
    
    return 0;

}
