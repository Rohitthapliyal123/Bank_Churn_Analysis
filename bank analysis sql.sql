-- SELECT * FROM bank_data;

-- Import data from csv

-- COPY Public."bank_data" 
-- FROM 'C:\Program Files\PostgreSQL\17\Bank Churn Analysis\Churn_Modelling.csv'
-- DELIMITER ','
-- CSV HEADER;

-- Change datatype of Balance column Otherwise copy command won't work...

-- ALTER TABLE bank_data 
-- ALTER COLUMN "Balance" TYPE FLOAT

-- Task 1 : TO Clean data (Missing values , duplicate , wrong format data)
-- SELECT COUNT(cte."CreditScore")  FROM (SELECT DISTINCT "CreditScore" FROM bank_data) AS cte

-- SELECT * FROM bank_data
-- WHERE "Geography" is null OR  "Balance" is null

-- SELECT * FROM bank_data
-- WHERE "HasCrCard" is null or "IsActiveMember" is null

-- SELECT DISTINCT * FROM bank_data
-- WHERE "Exited" is null or "NumOfProducts" is null

-- Result: There is no missing values


-- Task 2: check duplicate

-- SELECT * FROM bank_data

-- How to delete duplicate rows
-- DELETE FROM bank_data
-- WHERE ctid NOT IN (
--     SELECT MIN(ctid)
--     FROM bank_data
--     GROUP BY "RowNumber", "CustomerId", "Surname", "CreditScore", "Geography", "Gender", "Age", "Tenure", "Balance", "NumOfProducts", "HasCrCard", "IsActiveMember", "EstimatedSalary", "Exited"
-- );
-- Result: Now , Our data cleaning is done.

-- Task 3: Calculate columns 
SELECT DISTINCT "Geography"
FROM bank_data

-- Churn Percentage based on location
SELECT "Geography",
ROUND(SUM(CASE WHEN "Exited" = true THEN 1 ELSE 0 END) * 100/COUNT(*) , 2) as churn_percentage,
COUNT(*) AS customers
FROM bank_data
GROUP BY "Geography"

-- SELECT COUNT("Exited") 
-- FROM bank_data

-- Churn_rate based on gender

SELECT "Gender",
ROUND(SUM(CASE WHEN "Exited" = true THEN 1 ELSE 0 END) * 100/COUNT(*) , 2) as churn_percentage,
COUNT(*) AS customers,
SUM(CASE WHEN "Exited" = true THEN 1 ELSE 0 END) as churn_customers
FROM bank_data
GROUP BY "Gender"

-- Churn_rate based on age group

-- Temporary table to analyze data
WITH cte as (

SELECT * , 
 CASE 
    WHEN "Age" >= 18 AND "Age" <= 30 THEN 'Young'
	WHEN "Age" >= 31 AND "Age" <= 50 THEN 'Middle'
	ELSE 
	    'Senior Citizen'
 END AS age_category		
FROM bank_data

)

SELECT age_category , 
COUNT(*) AS customers , 
SUM(CASE WHEN "Exited" = true THEN 1 ELSE 0 END) AS churn_customers,
ROUND(SUM(CASE WHEN "Exited" = true THEN 1 ELSE 0 END) * 100 / COUNT(*) , 2) AS churn_rate
FROM cte
GROUP BY age_category
ORDER BY age_category DESC


-- 2) Customer tenure based calculation

SELECT DISTINCT MAX("Tenure") , MIN("Tenure") FROM bank_data

WITH tenure_cte AS (

SELECT * , 
 CASE 
    WHEN "Tenure" < 3 THEN 'New'
	WHEN "Tenure" < 7 THEN 'Mid-term'
	ELSE 'Long-Term'
 END AS "category_tenure"
FROM bank_data

)

SELECT "category_tenure" , 
ROUND(SUM(CASE WHEN "Exited" = true THEN 1 ELSE 0 END) * 100 / COUNT(*) , 2) AS "churned_customers",
COUNT(*) AS customers
FROM tenure_cte
GROUP BY "category_tenure"

SELECT * FROM bank_data

-- 3) Risk analysis
SELECT MAX("CreditScore"), MIN("CreditScore") , AVG("CreditScore") FROM bank_data

WITH risk_cte AS (

SELECT * , 
CASE 
  WHEN "CreditScore" < 600 THEN 'High risk'
  WHEN "CreditScore" < 750 THEN 'Moderate risk'
  ELSE 'Low risk'
END AS "risk_category"
FROM bank_data

)

SELECT "risk_category",
ROUND(SUM(CASE WHEN "Exited" = true THEN 1 ELSE 0 END) * 100 / COUNT(*) , 2) AS "churned_customers",
SUM(CASE WHEN "Exited" = true THEN 1 ELSE 0 END) AS churned_customers,
COUNT(*) AS "customers"
FROM risk_cte
GROUP BY "risk_category"

-- 4) Engagement analysis
SELECT * FROM bank_data

SELECT DISTINCT "NumOfProducts"
FROM bank_data

SELECT  MAX("Balance") , MIN("Balance") , AVG("Balance")
FROM bank_data

WITH engage_cte AS (

SELECT * ,
CASE 
  WHEN "NumOfProducts" = 1 AND "Balance" < 50000 THEN 'Low engaged'
  WHEN "NumOfProducts" <= 3 AND "Balance" < 100000 THEN 'Moderate engaged'
  ELSE 'Highly engaged'
END AS "category_engage"  
FROM bank_data  

)
SELECT "category_engage",
ROUND(SUM(CASE WHEN "Exited" = true THEN 1 ELSE 0 END) * 100 / COUNT(*) , 2) AS "churned_customers",
SUM(CASE WHEN "Exited" = true THEN 1 ELSE 0 END) AS churned_customers,
COUNT(*) AS "customers"
FROM engage_cte
GROUP BY "category_engage"

SELECT * FROM bank_data


-- Some important KPI

-- Overall churn_rate 
SELECT 
ROUND(SUM(CASE WHEN "Exited" = true THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) AS "churn percentage"
FROM bank_data

-- Overall retention rate
SELECT 
ROUND(SUM(CASE WHEN "Exited" = false THEN 1 ELSE 0 END) * 100 / COUNT(*), 2)
FROM bank_data

-- Average balance of churned customers
ALTER TABLE bank_data
ALTER COLUMN "Balance" TYPE numeric

SELECT ROUND(AVG("Balance"), 0) AS "Average balance"
FROM bank_data
WHERE "Exited" = true

-- Average salary of churned customers

SELECT ROUND(AVG("EstimatedSalary"), 0) AS "Average Salary"
FROM bank_data
WHERE "Exited" = true

-- High risk customers

SELECT COUNT("CreditScore") AS "high risk"
FROM bank_data
WHERE "CreditScore" < 600



