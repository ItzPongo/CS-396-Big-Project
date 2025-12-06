# Makefile for Personal Finance Tracker

CXX = g++
CXXFLAGS = -std=c++11 -Wall -Wextra -g
TARGET = finance_tracker
OBJS = main.o transaction.o json_handler.o

# Default target
all: $(TARGET)

# Link object files to create executable
$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJS)

# Compile main.cpp
main.o: main.cpp transaction.h json_handler.h
	$(CXX) $(CXXFLAGS) -c main.cpp

# Compile Transaction.cpp
transaction.o: transaction.cpp transaction.h
	$(CXX) $(CXXFLAGS) -c Transaction.cpp

# Compile JSONHandler.cpp
json_handler.o: json_handler.cpp json_handler.h transaction.h
	$(CXX) $(CXXFLAGS) -c json_handler.cpp

# Clean build artifacts
clean:
	rm -f $(OBJS) $(TARGET) *.json

# Clean and rebuild
rebuild: clean all

# Run the program
run: $(TARGET)
	./$(TARGET)

# Test target - creates sample data and runs analysis
test: $(TARGET)
	@echo "Creating test data..."
	@echo '{"transactions": [{"id": "1", "date": "11-15-2024", "category": "Groceries", "amount": 150.00, "description": "Weekly shopping", "type": "expense"}, {"id": "2", "date": "11-16-2024", "category": "Salary", "amount": 3000.00, "description": "Monthly salary", "type": "income"}], "categories": [{"name": "Groceries", "budget_limit": 500.0, "type": "expense"}]}' > finance_data.json
	@echo "Running Scheme analysis..."
	scheme --quiet < analysis.scm
	@echo "Test complete!"

.PHONY: all clean rebuild run test