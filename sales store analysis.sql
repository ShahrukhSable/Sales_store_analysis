CREATE DATABASE sales_store_db;

CREATE TABLE sales_store
(
	transaction_id VARCHAR(15),
	customer_id VARCHAR(15),
	customer_name VARCHAR(30),
	customer_age INT,
	gender VARCHAR(15),
	product_id VARCHAR(15),
	product_name VARCHAR(15),
	product_category VARCHAR(15),
	quantiy INT,
	prce FLOAT,
	payment_mode VARCHAR(15),
	purchase_date DATE,
	time_of_purchase TIME,
	status VARCHAR(15)
);

SET DATEFORMAT dmy
BULK INSERT sales_store
FROM 'C:\Users\Shahrukh Sable\Desktop\Data Analyst Portfolio Project\Sales Store Analysis- SQL\sales_store.csv'
	WITH (
		FIRSTROW=2,
		FIELDTERMINATOR=',',
		ROWTERMINATOR='\n'
	);

SELECT * FROM sales_store;

-- Creating a copy of dataswt

SELECT * INTO sales FROM sales_store;

SELECT * FROM sales_store;

SELECT * FROM sales;

-- Data Cleaning

-- To check for duplicate

SELECT transaction_id, COUNT(*)
FROM sales
GROUP BY transaction_id
HAVING COUNT(transaction_id) > 1;

-- Deleting duplicate records

WITH CTE AS (
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_id) AS Row_Num
FROM sales
)
DELETE FROM CTE
WHERE Row_Num = 2;

WITH CTE AS (
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_id) AS Row_Num
FROM sales
)
SELECT * FROM CTE
WHERE transaction_id IN ('TXN240646','TXN342128','TXN855235','TXN981773');

-- Correction of Headers

EXEC sp_rename 'sales.quantiy' , 'quantity', 'COLUMN';

EXEC sp_rename 'sales.prce' , 'price', 'COLUMN';

SELECT * FROM sales;

-- To check Datatype

SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sales';

-- To check Null Values

-- to check null count

DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = STRING_AGG(
    'SELECT ''' + COLUMN_NAME + ''' AS ColumnName, 
    COUNT(*) AS NullCount 
    FROM ' + QUOTENAME(TABLE_SCHEMA) + '.sales 
    WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL', 
    ' UNION ALL '
)
WITHIN GROUP (ORDER BY COLUMN_NAME)
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'sales'; 

-- Execte the dynamic SQL

EXEC sp_executesql @SQL;

-- Treating null values

SELECT * 
FROM sales
WHERE 
	transaction_id IS NULL
OR
	customer_id IS NULL
OR
	customer_name IS NULL
OR
	customer_age IS NULL
OR
	gender IS NULL
OR
	product_id IS NULL
OR 
	product_name IS NULL
OR
	product_category IS NULL
OR
	quantity IS NULL
OR
	price IS NULL
OR
	payment_mode IS NULL
OR 
	purchase_date IS NULL
OR 
	time_of_purchase IS NULL
OR
	status IS NULL;

DELETE FROM sales
WHERE transaction_id IS NULL;

-- Treating Null Values

SELECT * FROM sales
WHERE customer_name = 'Ehsaan Ram';

UPDATE sales
SET customer_id = 'CUST9494'
WHERE transaction_id = 'TXN977900';

SELECT * FROM sales
WHERE customer_name = 'Damini Raju';

UPDATE sales
SET customer_id = 'CUST1401'
WHERE transaction_id = 'TXN985663';

SELECT * FROM sales
WHERE customer_id = 'CUST1003';

UPDATE sales
SET customer_name = 'Mahika Saini',customer_age = 35, gender = 'Male'
WHERE transaction_id = 'TXN432798';

-- Data Cleaning for gender & payment_mode

SELECT DISTINCT gender FROM sales;

UPDATE sales
SET gender = 'M'
WHERE gender = 'Male';

UPDATE sales
SET gender = 'F'
WHERE gender = 'Female';

SELECT DISTINCT payment_mode FROM sales;

UPDATE sales
SET payment_mode = 'Credit Card'
WHERE payment_mode = 'CC';

-- DATA ANALYSIS
----------------------------------------------------------------------------------------

-- Q1. What ate the top 5 most selling products by quantity?

SELECT * FROM sales;

SELECT TOP 5 product_name, SUM(quantity) AS TotalQuantitySold 
FROM sales
WHERE status = 'delivered'
GROUP BY product_name
ORDER BY TotalQuantitySold DESC;

-- Business Problem: We don't know which products are the most in demand.

-- Business Impact: Helps prioritizes stock and boost sales through targeted promotions.

----------------------------------------------------------------------------------------------

-- Q2. Which products are most frequently cancelled?

SELECT TOP 5 product_name, COUNT(*) AS TotalCancelled 
FROM sales
WHERE status = 'Cancelled'
GROUP BY product_name
ORDER BY TotalCancelled DESC;

-- Business Problem: Frequent cancellations affect revenue and customer trust.

-- Business Impact: Identify low-selling items and either fix them or remove them.

-----------------------------------------------------------------------------------------------

-- Q3. What time of the day has the highest number of purchases?

SELECT 
	CASE 
		WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
		WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
		WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
		WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
	END AS time_of_day,
	COUNT(*) AS Total_orders
FROM sales
GROUP BY 
	CASE 
		WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
		WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
		WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
		WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
	END
ORDER BY Total_orders DESC;

-- Business Problem: Find peak sales times.

-- Business Impact: Optimize staffing, promotions, and server loads.

--------------------------------------------------------------------------------------------

--  Q4. Who are the Top 5 highest spending customers?

SELECT TOP 5 customer_name, 
	FORMAT(SUM(quantity * price), 'C0', 'en-IN')AS TotalSpend
FROM sales
GROUP BY customer_name
ORDER BY SUM(quantity * price) DESC;

-- Business Problem: Identift VIP customers.

-- Business Impact: Personalizeed offers, loyalty rewards, and retention.

----------------------------------------------------------------------------------------------

-- Q5. Which product categories generate the highest revenue?

SELECT TOP 5 product_category,
	FORMAT(SUM(quantity * price), 'C0', 'en-IN') AS Revenue
FROM sales
GROUP BY product_category
ORDER BY SUM(quantity * price) DESC;

-- Business Problem: Identify top-performing product categories.

/*
	Business Impact: 
		- Refine product stategy, supply chain, and promotions.
		- allowing the business to invest more in high-margin or high-demand categories.
*/

----------------------------------------------------------------------------------------------

-- Q6. What is the return/ cancellation rate per product category?

-- Return

SELECT product_category,
	FORMAT(COUNT(CASE WHEN status = 'returned' THEN 1 END) * 100.0 / COUNT(*), 'N3') + ' %' AS Return_Percent
FROM sales
GROUP BY product_category
ORDER BY Return_Percent DESC;

-- Cancellation

SELECT product_category,
	FORMAT(COUNT(CASE WHEN status = 'cancelled' THEN 1 END) * 100.0 / COUNT(*), 'N3') + ' %' AS Cancel_Percent
FROM sales
GROUP BY product_category
ORDER BY Cancel_Percent DESC;

-- Business Problem: Monitor dissatisfaction trends per category.

/*
	Business Imapct: 
		- Reduce returns, improve product descriptions/expectations.
		- Helps identify and fix product or logistics issues.
*/

-----------------------------------------------------------------------------------------------------

-- Q7. What is the most prefered payment mode?

SELECT payment_mode, COUNT(payment_mode) AS TotalCount
FROM sales
GROUP BY payment_mode
ORDER BY TotalCount DESC;

-- Business Problem: Know which payment options customers prefer.

-- Business Impact: Streamline payment processing, prioritize popular modes.

------------------------------------------------------------------------------------------------------

-- Q8. How does age group affect purchasing behavior?

SELECT 
	CASE
		WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
		WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
		WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
		ELSE '51+'
	END AS Customer_Age,
	FORMAT(SUM(quantity * price), 'C0', 'en-IN') AS Total_purchase
FROM sales
GROUP BY CASE
		WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
		WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
		WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
		ELSE '51+'
	END
ORDER BY SUM(quantity * price) DESC;

-- Business Problem: Understand customer demographics.

-- Business Impact: Targeted marketing and product recommendations by age group.

----------------------------------------------------------------------------------------------

-- Q9. What's the monthly sales trend?

-- Method 1

SELECT 
	FORMAT(purchase_date, 'yyyy-MM') AS Month_Year,
	FORMAT(SUM(quantity * price), 'C0', 'en-IN') AS Total_sales,
	SUM(quantity) AS Total_quantity
FROM sales
GROUP BY FORMAT(purchase_date, 'yyyy-MM');

-- Method 2

SELECT 
	YEAR(purchase_date) AS Years,
	MONTH(purchase_date) AS Months,
	FORMAT(SUM(quantity * price), 'C0', 'en-IN') AS Total_sales,
	SUM(quantity) AS Total_quantity
FROM sales
GROUP BY YEAR(purchase_date), MONTH(purchase_date)
ORDER BY YEAR(purchase_date), MONTH(purchase_date);

-- Business Problem: Sales fluctuations go unnoticed.

-- Business Impact: Plan inventory and marketing according to seasonal trends.

----------------------------------------------------------------------------------------------------

-- Q10. Are certain genders buying more specific product categories?

--Method 1

SELECT gender, product_category, COUNT(product_category) AS Total_Purchase
FROM sales
GROUP BY gender, product_category
ORDER BY Total_Purchase DESC;

-- Method 2

SELECT * 
FROM ( 
	SELECT gender,product_category
	FROM sales 
	) AS source_table
PIVOT (
	COUNT(gender)
	FOR gender IN ([M],[F])
	) AS pivot_table
ORDER BY product_category;

--Business Problem Solved: Gender-based product preferences.

--Business Impact: Personalized ads, gender-focused campaigns.