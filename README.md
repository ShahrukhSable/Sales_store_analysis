# 🛒 Sales Store Analysis using SQL

## 📌 Project Overview

This project focuses on analyzing retail sales data using SQL. It covers database creation, data cleaning, transformation, and exploratory analysis to derive meaningful business insights.

## Problem Statment
The store doesn't have a clear ideal about:-

1. Which products sell the most.
2. Customers preference.
3. Which items bring in the most profit.
4. Which things are going wrong in delivery or operations. Becuase of this, they are missing chances to earn more, losing customers, and making poor business decisions.

## Solution
They need proper reports and simple insights to understand their sales, customers, and product performance better.

## 🗂️ Database & Table Structure

* Database: `sales_store_db`
* Table: `sales_store`
* Key fields include:

  * Transaction ID
  * Customer details (ID, Name, Age, Gender)
  * Product details (ID, Name, Category)
  * Quantity & Price
  * Payment Mode
  * Purchase Date & Time
  * Order Status

## ⚙️ Key Steps Performed

### 🔹 Data Import

* Imported CSV data using `BULK INSERT`

### 🔹 Data Cleaning

* Removed duplicate transactions using CTE and `ROW_NUMBER()`
* Fixed incorrect column names (`quantiy` → `quantity`, `prce` → `price`)
* Checked null values dynamically across all columns

### 🔹 Data Validation

* Verified data types using `INFORMATION_SCHEMA`
* Ensured data consistency and accuracy

## 📊 Key Learnings

* Writing optimized SQL queries
* Using window functions for deduplication
* Dynamic SQL for null analysis
* Data cleaning best practices

## 🚀 Tools Used

* SQL Server
* CSV Dataset

## 📈 Future Enhancements

* Add advanced analytics queries (revenue trends, customer segmentation)
* Visualize insights using Power BI

---

⭐ If you found this useful, feel free to star the repo!
