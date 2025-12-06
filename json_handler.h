#ifndef JSON_HANDLER_H
#define JSON_HANDLER_H

#include "transaction.h"
#include <string>
#include <vector>
#include <fstream>

class JSONHandler {
public:
    // Write transactions and categories to JSON file
    static bool writeToJSON(const std::string& filename, 
                           const std::vector<Transaction>& transactions,
                           const std::vector<Category>& categories);
    
    // Read analysis results from JSON
    static bool readAnalysisResults(const std::string& filename,
                                   std::map<std::string, std::string>& results);
    
private:
    static std::string escapeJSON(const std::string& str);
    static std::string formatDouble(double value);
};

#endif