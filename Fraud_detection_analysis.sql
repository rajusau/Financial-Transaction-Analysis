-- Creating Fraud analysis Table

CREATE TABLE fraud_analysis (
    fraud_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id int not null,
    transaction_id INT NOT NULL,
    fraud_type VARCHAR(50) NOT NULL,
    fraud_details VARCHAR(255),
    detection_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);
drop table fraud_analysis;

-- transactions with more than double of the average transaction amount for individual account id

INSERT INTO fraud_analysis (account_id,transaction_id, fraud_type, fraud_details)
SELECT 
	t.account_id,
    t.transaction_id, 
    'Dynamic Large Transaction Fraud' AS fraud_type,
    CONCAT(
        'Transaction amount: $', t.amount, 
        ' exceeds ', ROUND(avg_amount * 2, 2), 
        ' (threshold)'
    ) AS fraud_details
FROM 
    transactions t
JOIN 
    (
        SELECT 
            account_id, 
            AVG(amount) AS avg_amount
        FROM 
            transactions
        GROUP BY 
            account_id
    ) t2 ON t.account_id = t2.account_id
WHERE 
    t.amount > t2.avg_amount * 2;
    

drop table consecutive_transactions;

-- insert accounts which inactive more than 1 years using transaction_date

-- Create a temporary table with gaps between consecutive transactions
CREATE TEMPORARY TABLE consecutive_transactions AS
SELECT 
    t1.account_id,
    t1.transaction_id AS current_transaction_id,
    t1.transaction_date AS current_transaction_date,
    t2.transaction_id AS previous_transaction_id,
    t2.transaction_date AS previous_transaction_date,
    DATEDIFF(t1.transaction_date, t2.transaction_date) AS days_between,
    t1.amount AS current_amount,
    t2.amount AS previous_amount
FROM
    transactions t1
        LEFT JOIN
    transactions t2 ON t1.account_id = t2.account_id
        AND t1.transaction_date > t2.transaction_date
WHERE
    NOT EXISTS( SELECT 
            1
        FROM
            transactions t3
        WHERE
            t3.account_id = t1.account_id
                AND t3.transaction_date < t1.transaction_date
                AND t3.transaction_date > t2.transaction_date); -- Ensures the join is only with the immediate preceding transaction
SELECT * FROM inactive_accounts;

-- Insert results into fraud_analysis table
INSERT INTO fraud_analysis (account_id, transaction_id, fraud_type, fraud_details)
SELECT 
    account_id,
    current_transaction_id,
    'Gap Between Transactions Exceeds 1 year' AS fraud_type,
    CONCAT('Gap between transaction on ',
            previous_transaction_date,
            ' transaction id ',
            previous_transaction_id,
            ' and ',
            current_transaction_date,
            ' is ',
            days_between,
            ' days.') AS fraud_details
FROM
    consecutive_transactions
WHERE
    days_between > 365
        AND current_amount > 40000
        AND previous_amount < current_amount
ORDER BY account_id;  -- 6 months threshold



-- > insights from the table -->


-- Identify customers or accounts with the most fraudulent activities
SELECT 
    c.customer_id,
    c.name,
    a.account_id,
    COUNT(f.fraud_id) AS fraud_count
FROM
    fraud_analysis f
        JOIN
    accounts a ON f.account_id = a.account_id
        JOIN
    customers c ON a.customer_id = c.customer_id
GROUP BY c.customer_id , a.account_id
HAVING fraud_count > 2
ORDER BY fraud_count DESC; 




-- Identify merchants with the highest incidence of fraudulent transactions
SELECT 
    m.merchant_id, m.name, COUNT(f.fraud_id) AS fraud_count
FROM
    fraud_analysis f
        JOIN
    transactions t ON f.transaction_id = t.transaction_id
        JOIN
    merchants m ON t.merchant_id = m.merchant_id
GROUP BY m.merchant_id , m.name
ORDER BY fraud_count DESC
LIMIT 10;  

