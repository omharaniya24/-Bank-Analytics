-- 1. Create Database
CREATE DATABASE bank_analysis;
USE bank_analysis;

-- 2. Create Table loans (
   Create Table loans (
    loan_id INT,
    customer_id INT,
    loan_amount DECIMAL(15,2),
    interest_amount DECIMAL(15,2),
    total_payment DECIMAL(15,2),
    loan_status VARCHAR(50),
    issue_date DATE,
    state VARCHAR(50),
    religion VARCHAR(50),
    product_group VARCHAR(50),
    grade VARCHAR(10),
    age INT,
    verified_status VARCHAR(20)
);

-- 3. Load CSV File (Change file path)
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/yourfile.csv'
INTO TABLE loans
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ================= KPI QUERIES =================

-- 1. Total Loan Amount Funded
SELECT SUM(loan_amount) AS total_funded FROM loans;

-- 2. Total Loans
SELECT COUNT(*) AS total_loans FROM loans;

-- 3. Total Collection
SELECT SUM(total_payment) AS total_collection FROM loans;

-- 4. Total Interest
SELECT SUM(interest_amount) AS total_interest FROM loans;

-- 5. Branch-Wise Performance (if branch column exists)
SELECT branch, 
       SUM(loan_amount) AS total_loans,
       SUM(interest_amount) AS interest
FROM loans
GROUP BY branch;

-- 6. State-Wise Loan
SELECT state, COUNT(*) AS total_loans
FROM loans
GROUP BY state;

-- 7. Religion-Wise Loan
SELECT religion, COUNT(*) AS total_loans
FROM loans
GROUP BY religion;

-- 8. Product Group-Wise Loan
SELECT product_group, COUNT(*) AS total_loans
FROM loans
GROUP BY product_group;

-- 9. Disbursement Trend
SELECT YEAR(issue_date) AS year,
       MONTH(issue_date) AS month,
       SUM(loan_amount) AS total_disbursed
FROM loans
GROUP BY year, month
ORDER BY year, month;

-- 10. Grade-Wise Loan
SELECT grade, COUNT(*) AS total_loans
FROM loans
GROUP BY grade;

-- 11. Default Loan Count
SELECT COUNT(*) AS default_loans
FROM loans
WHERE loan_status = 'Default';

-- 12. Delinquent Client Count
SELECT COUNT(DISTINCT customer_id) AS delinquent_clients
FROM loans
WHERE loan_status = 'Delinquent';

-- 13. Delinquent Loan Rate
SELECT 
    (COUNT(CASE WHEN loan_status = 'Delinquent' THEN 1 END) * 100.0 / COUNT(*)) AS delinquent_rate
FROM loans;

-- 14. Default Loan Rate
SELECT 
    (COUNT(CASE WHEN loan_status = 'Default' THEN 1 END) * 100.0 / COUNT(*)) AS default_rate
FROM loans;

-- 15. Loan Status-Wise Loan
SELECT loan_status, COUNT(*) AS total_loans
FROM loans
GROUP BY loan_status;

-- 16. Age Group-Wise Loan
SELECT 
    CASE 
        WHEN age < 25 THEN '18-25'
        WHEN age BETWEEN 25 AND 40 THEN '25-40'
        WHEN age BETWEEN 40 AND 60 THEN '40-60'
        ELSE '60+'
    END AS age_group,
    COUNT(*) AS total_loans
FROM loans
GROUP BY age_group;

-- 17. Loan Maturity (if maturity_date exists)
SELECT AVG(DATEDIFF(maturity_date, issue_date)) AS avg_maturity_days
FROM loans;

-- 18. No Verified Loans
SELECT COUNT(*) AS unverified_loans
FROM loans
WHERE verified_status = 'Not Verified';