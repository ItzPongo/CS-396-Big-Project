# Personal Finance Tracker

A multi-language financial analysis system that combines C++ for data management and user interaction with Racket Scheme for functional data analysis.

## Overview

This project demonstrates polyglot programming by integrating:
- **C++**: Interactive menu system, transaction management, and JSON I/O
- **Racket Scheme**: Functional programming for financial analysis and calculations

## Features

- Add and manage financial transactions
- Create and track budget categories
- View all transactions with formatted output
- Automated financial analysis with recommendations
- Budget status monitoring with warnings
- JSON-based data interchange between languages

## Project Structure

```
.
├── main.cpp              # Main program with interactive menu
├── transaction.h         # Transaction and Account class definitions
├── transaction.cpp       # Transaction and Account implementations
├── json_handler.h        # JSON reading/writing interface
├── json_handler.cpp      # JSON handling implementation
├── analysis.scm          # Racket Scheme financial analysis
├── json_parser.scm       # Custom JSON parser for Scheme
├── Makefile             # Build configuration
├── finance_data.json    # Generated transaction data
├── PLACE RACKET FOLDER HERE WITH racket.exe
└── analysis_results.json # Generated analysis results
```

## Prerequisites

### Required Software
- **C++ Compiler**: g++
- **Racket**: Download from [racket-lang.org](https://racket-lang.org/)
- **Make**: For building the C++ project

### Installation

1. Install [Racket](https://download.racket-lang.org/)
2. Add Racket to the folder or note the installation location

## Building the Project

### Using Make
```bash
make
```

## Running the Program

```bash
finance_tracker.exe
```

## Usage

### Main Menu Options

```
=== Personal Finance Tracker ===
1. Add Transaction
2. Add Category
3. View All Transactions
4. Run Analysis
5. Exit
```

### Adding a Transaction

1. Select option **1** from the menu
2. Enter transaction details:
   - **ID**: Unique identifier
   - **Date**: Format MM-DD-YYYY
   - **Category**: Category name
   - **Amount**: Dollar amount
   - **Type**: Either "income" or "expense"
   - **Description**: Brief description

### Adding a Category

1. Select option **2** from the menu
2. Enter category details:
   - **Category Name**: Name of the category
   - **Budget Limit**: Maximum spending allowed
   - **Type**: Either "income" or "expense"

### Viewing Transactions

Select option **3** to see a formatted table of all transactions with the current account balance.

### Running Analysis

1. Select option **4** from the menu
2. The system will:
   - Export data to `finance_data.json`
   - Call the Racket Scheme analyzer
   - Generate `analysis_results.json`
   - Display comprehensive financial analysis

#### Analysis Output Includes:
- Total income and expenses
- Net savings
- Spending breakdown by category
- Budget status for each category
- Personalized financial recommendations

## Configuration

### Updating Racket Path

If Racket is installed in a different location, update `main.cpp`:

```cpp
// Line 111 in main.cpp
std::string command = "\"YOUR_RACKET_PATH\\racket.exe\" analysis.scm";
```

Replace `YOUR_RACKET_PATH` with your actual Racket installation directory.

## How It Works

### Data Flow

1. **User Input** -> C++ program collects transaction data
2. **Export** -> C++ writes data to `finance_data.json`
3. **Analysis** -> Racket Scheme reads JSON and performs calculations
4. **Results** -> Scheme writes analysis to `analysis_results.json`
5. **Display** -> C++ reads and displays results to user

### Financial Analysis Logic

The Scheme analyzer calculates:
- **Savings Rate**: `(net_savings / total_income) * 100`
- **Budget Status**: Compares spending to budget limits
- **Recommendations**: Based on savings rate thresholds
  - < 0%: Overspending warning
  - < 10%: Low savings notice
  - < 20%: Encouragement to save more
  - ≥ 20%: Positive reinforcement

## Code Architecture

### C++ Components

- **Transaction Class**: Manages individual transactions
- **Category Class**: Tracks budget categories
- **Account Class**: Maintains transaction history and balance
- **JSONHandler**: Reads/writes JSON files

### Scheme Components

- **json_parser.scm**: Custom JSON parser
  - Reads JSON into association lists
  - Handles objects, arrays, strings, numbers, booleans, and null
  
- **analysis.scm**: Financial analysis engine
  - Functional programming approach
  - Pure functions for calculations
  - Budget monitoring and recommendations

## Example

```
=== Personal Finance Tracker ===
1. Add Transaction
2. Add Category
3. View All Transactions
4. Run Analysis
5. Exit
Choose an option: 1

=== Add New Transaction ===
ID: 001
Date (MM-DD-YYYY): 12-05-2025
Category: Groceries
Amount: $120.50
Type (income/expense): expense
Description: Weekly shopping

Transaction added successfully!

Choose an option: 4

=== Running Financial Analysis ===
Data exported to finance_data.json
Calling Scheme analyzer...
Analysis complete. Results written to analysis_results.json

=== Analysis Results ===
Total Income: $2000.00
Total Expenses: $300.70
Net Savings: $1699.30

--- Spending by Category ---
Groceries: $180.80
Entertainment: $45.00
Utilities: $75.20

--- Budget Status ---
Groceries: OK - $319.20 remaining
Entertainment: OK - $155.00 remaining
Utilities: OK - $224.80 remaining

--- Recommendation ---
Excellent! You're saving well. Keep up the good work!
```
