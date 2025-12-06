#ifndef TRANSACTION_H
#define TRANSACTION_H

#include <string>
#include <vector>
#include <map>

class Transaction {
private:
    std::string id;
    std::string date;
    std::string category;
    double amount;
    std::string description;
    std::string type; // "income" or "expense"

public:
    Transaction(const std::string& id, const std::string& date, 
                const std::string& category, double amount, 
                const std::string& description, const std::string& type);
    
    // Getters
    std::string getId() const { return id; }
    std::string getDate() const { return date; }
    std::string getCategory() const { return category; }
    double getAmount() const { return amount; }
    std::string getDescription() const { return description; }
    std::string getType() const { return type; }
    
    // Setters
    void setCategory(const std::string& cat) { category = cat; }
    void setAmount(double amt) { amount = amt; }
    void setDescription(const std::string& desc) { description = desc; }
    
    // Convert to JSON-compatible map
    std::map<std::string, std::string> toMap() const;
};

class Category {
private:
    std::string name;
    double budgetLimit;
    std::string type; // "expense" or "income"

public:
    Category(const std::string& name, double budgetLimit, const std::string& type);
    
    std::string getName() const { return name; }
    double getBudgetLimit() const { return budgetLimit; }
    std::string getType() const { return type; }
    
    void setBudgetLimit(double limit) { budgetLimit = limit; }
};

class Account {
private:
    std::vector<Transaction> transactions;
    std::vector<Category> categories;
    double balance;

public:
    Account();
    
    void addTransaction(const Transaction& trans);
    void addCategory(const Category& cat);
    
    const std::vector<Transaction>& getTransactions() const { return transactions; }
    const std::vector<Category>& getCategories() const { return categories; }
    double getBalance() const { return balance; }
    
    void updateBalance();
    Category* findCategory(const std::string& name);
};

#endif