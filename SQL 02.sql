-- ============================================================
--  BANKING PROJECT — MySQL Queries
--  Table : banking_transactions
--  Source: Debit and Credit banking_data.xlsx
--  Date  : 2024 (Jan – Dec)
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- STEP 0 : Create & load the table (run once)
-- ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS banking_transactions (
    customer_id        VARCHAR(50),
    customer_name      VARCHAR(100),
    account_number     BIGINT,
    transaction_date   DATE,
    transaction_type   VARCHAR(10),   -- 'Credit' or 'Debit'
    amount             DECIMAL(15,2),
    balance            DECIMAL(15,2),
    description        VARCHAR(100),
    branch             VARCHAR(50),
    transaction_method VARCHAR(30),
    currency           VARCHAR(10),
    bank_name          VARCHAR(50)
);


-- ============================================================
--  1. OVERALL TOTAL CREDIT & TOTAL DEBIT
-- ============================================================

SELECT
    transaction_type,
    COUNT(*)                          AS total_transactions,
    SUM(amount)                       AS total_amount,
    ROUND(AVG(amount), 2)             AS avg_amount,
    MIN(amount)                       AS min_amount,
    MAX(amount)                       AS max_amount
FROM banking_transactions
GROUP BY transaction_type
ORDER BY transaction_type;


-- ============================================================
--  2. NET CASH FLOW  (Credit − Debit)
-- ============================================================

SELECT
    SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END)  AS total_credit,
    SUM(CASE WHEN transaction_type = 'Debit'  THEN amount ELSE 0 END)  AS total_debit,
    SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END)
  - SUM(CASE WHEN transaction_type = 'Debit'  THEN amount ELSE 0 END)  AS net_cash_flow,
    COUNT(*)                                                             AS total_transactions
FROM banking_transactions;


-- ============================================================
--  3. MONTHLY TOTAL CREDIT & TOTAL DEBIT
-- ============================================================

SELECT
    DATE_FORMAT(transaction_date, '%b %Y')                              AS month_label,
    DATE_FORMAT(transaction_date, '%Y-%m')                              AS month_sort,
    SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END)  AS total_credit,
    SUM(CASE WHEN transaction_type = 'Debit'  THEN amount ELSE 0 END)  AS total_debit,
    SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END)
  - SUM(CASE WHEN transaction_type = 'Debit'  THEN amount ELSE 0 END)  AS net_flow,
    COUNT(CASE WHEN transaction_type = 'Credit' THEN 1 END)             AS credit_count,
    COUNT(CASE WHEN transaction_type = 'Debit'  THEN 1 END)             AS debit_count
FROM banking_transactions
GROUP BY month_sort, month_label
ORDER BY month_sort;


-- ============================================================
--  4. CREDIT & DEBIT BY BRANCH
-- ============================================================

SELECT
    branch,
    SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END)  AS total_credit,
    SUM(CASE WHEN transaction_type = 'Debit'  THEN amount ELSE 0 END)  AS total_debit,
    SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END)
  - SUM(CASE WHEN transaction_type = 'Debit'  THEN amount ELSE 0 END)  AS net_flow,
    SUM(amount)                                                          AS total_volume,
    ROUND(
        100.0 * SUM(amount) / SUM(SUM(amount)) OVER (), 2
    )                                                                    AS volume_pct
FROM banking_transactions
GROUP BY branch
ORDER BY total_volume DESC;


-- ============================================================
--  5. CREDIT & DEBIT BY BANK
-- ============================================================

SELECT
    bank_name,
    SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END)  AS total_credit,
    SUM(CASE WHEN transaction_type = 'Debit'  THEN amount ELSE 0 END)  AS total_debit,
    SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END)
  - SUM(CASE WHEN transaction_type = 'Debit'  THEN amount ELSE 0 END)  AS net_flow,
    SUM(amount)                                                          AS total_volume,
    ROUND(
        100.0 * SUM(amount) / SUM(SUM(amount)) OVER (), 2
    )                                                                    AS volume_pct
FROM banking_transactions
GROUP BY bank_name
ORDER BY total_volume DESC;


-- ============================================================
--  6. CREDIT & DEBIT BY TRANSACTION METHOD
-- ============================================================

SELECT
    transaction_method,
    SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END)  AS total_credit,
    SUM(CASE WHEN transaction_type = 'Debit'  THEN amount ELSE 0 END)  AS total_debit,
    SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END)
  - SUM(CASE WHEN transaction_type = 'Debit'  THEN amount ELSE 0 END)  AS net_flow,
    COUNT(*)                                                             AS total_transactions
FROM banking_transactions
GROUP BY transaction_method
ORDER BY total_transactions DESC;


-- ============================================================
--  7. CREDIT & DEBIT BY DESCRIPTION / CATEGORY
-- ============================================================

SELECT
    description                                                          AS category,
    SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END)  AS total_credit,
    SUM(CASE WHEN transaction_type = 'Debit'  THEN amount ELSE 0 END)  AS total_debit,
    SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END)
  - SUM(CASE WHEN transaction_type = 'Debit'  THEN amount ELSE 0 END)  AS net_flow,
    COUNT(*)                                                             AS transaction_count,
    ROUND(AVG(amount), 2)                                               AS avg_amount
FROM banking_transactions
GROUP BY description
ORDER BY (total_credit + total_debit) DESC;


-- ============================================================
--  8. TOP 10 CUSTOMERS BY TOTAL CREDIT RECEIVED
-- ============================================================

SELECT
    customer_name,
    COUNT(*)              AS credit_transactions,
    SUM(amount)           AS total_credit_received,
    ROUND(AVG(amount), 2) AS avg_credit
FROM banking_transactions
WHERE transaction_type = 'Credit'
GROUP BY customer_name
ORDER BY total_credit_received DESC
LIMIT 10;


-- ============================================================
--  9. TOP 10 CUSTOMERS BY TOTAL DEBIT SPENT
-- ============================================================

SELECT
    customer_name,
    COUNT(*)              AS debit_transactions,
    SUM(amount)           AS total_debit_spent,
    ROUND(AVG(amount), 2) AS avg_debit
FROM banking_transactions
WHERE transaction_type = 'Debit'
GROUP BY customer_name
ORDER BY total_debit_spent DESC
LIMIT 10;


-- ============================================================
--  10. DAILY CREDIT & DEBIT TREND
-- ============================================================

SELECT
    transaction_date,
    SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END)  AS daily_credit,
    SUM(CASE WHEN transaction_type = 'Debit'  THEN amount ELSE 0 END)  AS daily_debit,
    SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END)
  - SUM(CASE WHEN transaction_type = 'Debit'  THEN amount ELSE 0 END)  AS daily_net
FROM banking_transactions
GROUP BY transaction_date
ORDER BY transaction_date;


-- ============================================================
--  11. CREDIT vs DEBIT RATIO PER BRANCH (monthly)
-- ============================================================

SELECT
    branch,
    DATE_FORMAT(transaction_date, '%b %Y')                              AS month_label,
    SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END)  AS credit,
    SUM(CASE WHEN transaction_type = 'Debit'  THEN amount ELSE 0 END)  AS debit,
    ROUND(
        SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END) /
        NULLIF(SUM(CASE WHEN transaction_type = 'Debit' THEN amount ELSE 0 END), 0),
    4)                                                                   AS credit_to_debit_ratio
FROM banking_transactions
GROUP BY branch, DATE_FORMAT(transaction_date, '%Y-%m'), month_label
ORDER BY branch, DATE_FORMAT(transaction_date, '%Y-%m');
