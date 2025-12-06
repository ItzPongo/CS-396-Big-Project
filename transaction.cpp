#include "transaction.h"
#include <iomanip>
#include <sstream>

Transaction::Transaction(const std::string& id, const std::string& date, 
                        const std::string& category, double amount, 
                        const std::string& description, const std::string& type)
    : id(id), date(date), category(category), amount(amount), 
      description(description), type(type) {}

std::map<std::string, std::string> Transaction::toMap() const {
    std::map<std::string, std::string> m;
    m["id"] = id;
    m["date"] = date;
    m["category"] = category;
    
    std::ostringstream oss;
    oss << std::fixed << std::setprecision(2) << amount;
    m["amount"] = oss.str();
    
    m["description"] = description;
    m["type"] = type;
    return m;
}

Category::Category(const std::string& name, double budgetLimit, const std::string& type)
    : name(name), budgetLimit(budgetLimit), type(type) {}

Account::Account() : balance(0.0) {}

void Account::addTransaction(const Transaction& trans) {
    transactions.push_back(trans);
    updateBalance();
}

void Account::addCategory(const Category& cat) {
    categories.push_back(cat);
}

void Account::updateBalance() {
    balance = 0.0;
    for (const auto& trans : transactions) {
        if (trans.getType() == "income") {
            balance += trans.getAmount();
        } else {
            balance -= trans.getAmount();
        }
    }
}

Category* Account::findCategory(const std::string& name) {
    for (auto& cat : categories) {
        if (cat.getName() == name) {
            return &cat;
        }
    }
    return nullptr;
}