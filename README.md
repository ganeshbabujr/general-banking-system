# General Banking System (Oracle PL/SQL)

A simplified **General Banking System** built using **Oracle PL/SQL**. This project simulates essential banking functionalities such as account creation (savings and current), withdrawals, fund transactions, and account statement generation. It demonstrates the use of procedures, functions, and basic SQL logic to model core banking operations.

---

## 📌 Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Technologies Used](#technologies-used)
- [Database Schema](#database-schema)
- [How to Run](#how-to-run)
- [Sample Usage](#sample-usage)
- [Folder Structure](#folder-structure)
- [Author](#author)

---

## 🔍 Project Overview

This **Oracle PL/SQL** project acts as a backend simulation of a banking environment. It is designed for developers looking to implement core banking operations using SQL and PL/SQL, such as managing accounts, performing transactions, and generating statements.

---

## ✅ Features

- **Account Creation** (Savings / Current accounts)
- **Withdrawals** and **Fund Transfers**
- **Balance Inquiry** for each account
- **Statement Generation** (Mini and Full Statements)
- Input validation and error handling through PL/SQL procedures and triggers
- Stored procedures, functions, triggers, and packages used for modularity and reusability

---

## 🛠 Technologies Used

- **Database**: Oracle 12c/19c
- **Language**: PL/SQL (Procedures, Functions, Triggers)
- **Tools**: SQL Developer, TOAD, DBeaver

---

## 🗃️ Database Schema

The project includes the following key tables and their relationships:

- **ACCOUNTS**: Stores account details, including account type (savings/current), balance, and account owner.
- **TRANSACTIONS**: Logs all debit and credit transactions, including transaction date, amount, and type.
- **STATEMENTS**: Stores generated statements, either mini or full.

sql
-- Example Schema: Accounts Table
CREATE TABLE ACCOUNTS (
    ACCOUNT_ID NUMBER PRIMARY KEY,
    ACCOUNT_TYPE VARCHAR2(20),
    BALANCE NUMBER,
    CUSTOMER_NAME VARCHAR2(100)
);

-- Example Schema: Transactions Table
CREATE TABLE TRANSACTIONS (
    TRANSACTION_ID NUMBER PRIMARY KEY,
    ACCOUNT_ID NUMBER,
    TRANSACTION_TYPE VARCHAR2(10),  -- 'DEBIT' or 'CREDIT'
    AMOUNT NUMBER,
    TRANSACTION_DATE DATE,
    FOREIGN KEY (ACCOUNT_ID) REFERENCES ACCOUNTS(ACCOUNT_ID)
);

🚀 How to Run
1. Clone the repository: git clone https://github.com/ganeshbabujr/general-banking-system.git

2. Set up the database schema in Oracle SQL Developer (or your preferred tool): Run the schema creation script to set up tables.
  @schema/create_tables.sql
  @schema/insert_sample_data.sql

3. Run the SQL scripts for the banking operations:
The project includes various modules that handle account creation, withdrawals, transactions, and statement generation.

Account Creation (account_creation.sql):

-- Create a savings account for Ganesh
EXEC create_account('Ganesh', 'SAVINGS', 5000);

-- Create a current account for Kumar
EXEC create_account('Kumar', 'CURRENT', 10000);

-- Withdraw 2000 from Ganesh's account
EXEC withdraw_amount(1001, 2000);

-- Transfer 1500 from Ganesh's account (1001) to Kumar's account (1002)
EXEC transfer_funds(1001, 1002, 1500);

-- Generate statement for Ganesh's account
EXEC generate_statement(1001);

🧪 Sample Usage
Create Account: This procedure creates a new account for a customer.

-- Create a new savings account for 'John Doe' with an initial balance of 10000
EXEC create_account('John Doe', 'SAVINGS', 10000);

-- Withdraw 500 from account ID 1001
EXEC withdraw_amount(1001, 500);

-- Transfer 2000 from account 1001 to account 1002
EXEC transfer_funds(1001, 1002, 2000);

-- Transfer 2000 from account 1001 to account 1002
EXEC transfer_funds(1001, 1002, 2000);

-- Generate a mini statement for account 1001
EXEC generate_statement(1001);

-- Check balance of account ID 1001
SELECT get_balance(1001) FROM dual;

📁 Folder Structure

general-banking-system/
├── schema/
│   ├── create_tables.sql        # Create table schema
│   └── insert_sample_data.sql   # Insert sample data
├── modules/
│   ├── account_creation.sql     # Account creation procedures
│   ├── withdrawal.sql           # Withdrawal procedures
│   ├── transactions.sql         # Fund transfer procedures
│   ├── statements.sql           # Statement generation procedures
├── README.md

👨‍💻 Author
Ganesh Babu J R
Oracle PL/SQL Developer | Backend Systems Enthusiast


---

This is a complete and detailed `README.md` that explains all aspects of your project. Let me know if you need any more adjustments or additional content!
