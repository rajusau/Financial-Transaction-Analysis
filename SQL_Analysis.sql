-- Data Exploration and Cleaning

-- Check for missing values in the customers table
SELECT * FROM customers WHERE name IS NULL OR date_of_birth IS NULL;

-- Ensure customer_since is aligned with the first account creation date
SELECT c.customer_id, c.customer_since, MIN(a.creation_date) AS first_account_creation
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
GROUP BY c.customer_id
HAVING c.customer_since > MIN(a.creation_date);

-- Check for invalid transactions (before account creation)
SELECT t.transaction_id, t.transaction_date, a.creation_date
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
WHERE t.transaction_date < a.creation_date;

-- evrything looks good next analysis

-- Trend Identification Using SQL

-- Find total spending per customer

SELECT 
    c.customer_id, 
    c.name, 
    SUM(t.amount) AS total_spent
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN transactions t ON a.account_id = t.account_id
GROUP BY c.customer_id, c.name
ORDER BY customer_id DESC;



-- Find top industries by transaction amount

SELECT 
    m.industry, 
    SUM(t.amount) AS total_sales
FROM merchants m
JOIN transactions t ON m.merchant_id = t.merchant_id
GROUP BY m.industry
ORDER BY total_sales DESC;


-- Identify transactions flagged as fraud
SELECT 
    t.transaction_id, 
    t.amount, 
    t.transaction_date, 
    f.fraud_type, 
    f.fraud_details
FROM transactions t
JOIN fraud_analysis f ON t.transaction_id = f.transaction_id
WHERE f.fraud_type IS NOT NULL;


-- Analyze fraud cases over time
SELECT 
    DATE_FORMAT(f.detection_date, '%Y-%m') AS fraud_month, 
    COUNT(f.fraud_id) AS fraud_cases
FROM fraud_analysis f
GROUP BY fraud_month
ORDER BY fraud_month;


-- Index on foreign key columns to speed up joins
CREATE INDEX idx_account_id ON transactions(account_id);
CREATE INDEX idx_customer_id ON accounts(customer_id);
CREATE INDEX idx_merchant_id ON transactions(merchant_id);


-- Optimize transaction aggregation by pre-filtering large datasets
-- total spent by customers after 2023-01-01

SELECT 
    c.customer_id, 
    c.name, 
    SUM(t.amount) AS total_spent
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN (
    SELECT account_id, amount FROM transactions WHERE transaction_date > '2023-01-01'
) t ON a.account_id = t.account_id
GROUP BY c.customer_id, c.name
ORDER BY customer_id DESC;

-- CLV ( Customer Lifetime Value) 

SELECT 
    c.customer_id, 
    c.name, 
    SUM(t.amount) AS lifetime_value
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN transactions t ON a.account_id = t.account_id
GROUP BY c.customer_id, c.name
ORDER BY lifetime_value DESC;

-- Customer Segmentation by Account Type

SELECT 
    a.account_type, 
    COUNT(DISTINCT c.customer_id) AS number_of_customers, 
    SUM(t.amount) AS total_spent
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
JOIN transactions t ON a.account_id = t.account_id
GROUP BY a.account_type
ORDER BY total_spent DESC;

-- transaction by day_of_week

SELECT 
    DAYNAME(transaction_date) AS day_of_week,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount
FROM
    transactions
GROUP BY day_of_week
ORDER BY total_amount DESC;

-- ORDER BY transaction_count DESC;
-- ORDER BY FIELD(day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

-- Peak Transaction Time 

SELECT 
    HOUR(transaction_time) AS transaction_hour,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount
FROM
    transactions
GROUP BY transaction_hour
ORDER BY total_amount DESC;

-- Calculate the percentage of fraudulent transactions in each industry.

SELECT 
    m.industry, 
    COUNT(f.fraud_id) AS fraud_cases, 
    COUNT(t.transaction_id) AS total_transactions,
    ROUND((COUNT(f.fraud_id) / COUNT(t.transaction_id)) * 100, 2) AS fraud_rate
FROM merchants m
JOIN transactions t ON m.merchant_id = t.merchant_id
LEFT JOIN fraud_analysis f ON t.transaction_id = f.transaction_id
GROUP BY m.industry
ORDER BY fraud_rate DESC;

-- Identify accounts with the highest number of fraud incidents.

SELECT 
    a.account_id, 
    c.customer_id, 
    c.name, 
    COUNT(f.fraud_id) AS fraud_cases
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
JOIN fraud_analysis f ON a.account_id = f.account_id
GROUP BY a.account_id, c.customer_id, c.name
HAVING fraud_cases > 1
ORDER BY fraud_cases DESC;

-- Identify accounts that haven't had any transactions in a specified period eg. 1 year

SELECT 
    a.account_id, 
    c.customer_id, 
    c.name, 
    a.balance, 
    MAX(t.transaction_date) AS last_transaction_date
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
LEFT JOIN transactions t ON a.account_id = t.account_id
GROUP BY a.account_id, c.customer_id, c.name, a.balance
HAVING last_transaction_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR) OR last_transaction_date IS NULL;



-- Most Valuable Customer Of the Company

WITH TopTransactions AS (
    SELECT 
        c.customer_id,
        c.name,
        COUNT(t.transaction_id) AS total_transactions
    FROM 
        customers c
    JOIN 
        accounts a ON c.customer_id = a.customer_id
    JOIN 
        transactions t ON a.account_id = t.account_id
    GROUP BY 
        c.customer_id, c.name
    ORDER BY 
        total_transactions DESC
    LIMIT 1
),
TopSpending AS (
    SELECT 
        c.customer_id,
        c.name,
        SUM(t.amount) AS total_spent
    FROM 
        customers c
    JOIN 
        accounts a ON c.customer_id = a.customer_id
    JOIN 
        transactions t ON a.account_id = t.account_id
    GROUP BY 
        c.customer_id, c.name
    ORDER BY 
        total_spent DESC
    LIMIT 1
),
TopTenure AS (
    SELECT 
        c.customer_id,
        c.name,
        MIN(c.customer_since) AS customer_since
    FROM 
        customers c
    GROUP BY 
        c.customer_id, c.name
    ORDER BY 
        customer_since
    LIMIT 1
)

-- Combine results from all metrics
SELECT 
    'Most Transactions' AS Metric,
    t.customer_id,
    t.name,
    t.total_transactions AS Value
FROM 
    TopTransactions t
UNION ALL
SELECT 
    'Highest Spending' AS Metric,
    s.customer_id,
    s.name,
    s.total_spent AS Value
FROM 
    TopSpending s
UNION ALL
SELECT 
    'Longest Tenure' AS Metric,
    te.customer_id,
    te.name,
    te.customer_since AS Value
FROM 
    TopTenure te;
