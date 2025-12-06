#include "json_handler.h"
#include <sstream>
#include <iomanip>
#include <iostream>

std::string JSONHandler::escapeJSON(const std::string& str) {
    std::string result;
    for (char c : str) {
        switch (c) {
            case '"': result += "\\\""; break;
            case '\\': result += "\\\\"; break;
            case '\n': result += "\\n"; break;
            case '\r': result += "\\r"; break;
            case '\t': result += "\\t"; break;
            default: result += c;
        }
    }
    return result;
}

std::string JSONHandler::formatDouble(double value) {
    std::ostringstream oss;
    oss << std::fixed << std::setprecision(2) << value;
    return oss.str();
}

bool JSONHandler::writeToJSON(const std::string& filename, 
                              const std::vector<Transaction>& transactions,
                              const std::vector<Category>& categories) {
    std::ofstream file(filename);
    if (!file.is_open()) {
        std::cerr << "Error: Could not open file " << filename << " for writing." << std::endl;
        return false;
    }
    
    file << "{\n";
    
    // Write transactions
    file << "  \"transactions\": [\n";
    for (size_t i = 0; i < transactions.size(); ++i) {
        const auto& t = transactions[i];
        file << "    {\n";
        file << "      \"id\": \"" << escapeJSON(t.getId()) << "\",\n";
        file << "      \"date\": \"" << escapeJSON(t.getDate()) << "\",\n";
        file << "      \"category\": \"" << escapeJSON(t.getCategory()) << "\",\n";
        file << "      \"amount\": " << formatDouble(t.getAmount()) << ",\n";
        file << "      \"description\": \"" << escapeJSON(t.getDescription()) << "\",\n";
        file << "      \"type\": \"" << escapeJSON(t.getType()) << "\"\n";
        file << "    }";
        if (i < transactions.size() - 1) file << ",";
        file << "\n";
    }
    file << "  ],\n";
    
    // Write categories
    file << "  \"categories\": [\n";
    for (size_t i = 0; i < categories.size(); ++i) {
        const auto& c = categories[i];
        file << "    {\n";
        file << "      \"name\": \"" << escapeJSON(c.getName()) << "\",\n";
        file << "      \"budget_limit\": " << formatDouble(c.getBudgetLimit()) << ",\n";
        file << "      \"type\": \"" << escapeJSON(c.getType()) << "\"\n";
        file << "    }";
        if (i < categories.size() - 1) file << ",";
        file << "\n";
    }
    file << "  ]\n";
    
    file << "}\n";
    file.close();
    return true;
}

bool JSONHandler::readAnalysisResults(const std::string& filename,
                                     std::map<std::string, std::string>& results) {
    std::ifstream file(filename);
    if (!file.is_open()) {
        std::cerr << "Error: Could not open file " << filename << " for reading." << std::endl;
        return false;
    }
    
    results.clear();
    std::string line;
    std::string currentKey;
    
    while (std::getline(file, line)) {
        // Simple JSON parsing for results
        size_t colonPos = line.find(':');
        if (colonPos != std::string::npos) {
            // Extract key
            size_t keyStart = line.find('"');
            size_t keyEnd = line.find('"', keyStart + 1);
            if (keyStart != std::string::npos && keyEnd != std::string::npos) {
                currentKey = line.substr(keyStart + 1, keyEnd - keyStart - 1);
                
                // Extract value (could be string or number)
                size_t valueStart = line.find_first_not_of(" \t", colonPos + 1);
                if (valueStart != std::string::npos) {
                    std::string value = line.substr(valueStart);
                    // Remove trailing comma and whitespace
                    size_t valueEnd = value.find_last_not_of(",\n\r\t ");
                    if (valueEnd != std::string::npos) {
                        value = value.substr(0, valueEnd + 1);
                    }
                    // Remove quotes if present
                    if (value.front() == '"' && value.back() == '"') {
                        value = value.substr(1, value.length() - 2);
                    }
                    results[currentKey] = value;
                }
            }
        }
    }
    
    file.close();
    return true;
}