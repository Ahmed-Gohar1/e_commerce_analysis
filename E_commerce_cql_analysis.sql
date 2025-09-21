-- SQL Analyses

-- Calculate high-level business metrics:

-- - Total number of customers

SELECT * FROM customers;
SELECT COUNT(DISTINCT customerid)
FROM customers; -- 4372

-- - Total number of orders

SELECT * FROM orders;
SELECT COUNT(DISTINCT invoiceno)
FROM orders; -- 25900

-- - Total revenue

SELECT * FROM orders;
SELECT ROUND(SUM(quantity * unitprice)) AS total_revinue
FROM orders; -- 590571

-- - Average order value

SELECT * FROM orders;
SELECT ROUND(AVG(quantity * unitprice)) AS total_revinue
FROM orders; -- 23 

-- Analyze how customers interact with the platform:

-- - Count orders per customer

SELECT customerid, count(invoiceno) AS orders
FROM orders
WHERE customerid IS NOT NULL
GROUP BY customerid;

-- - Identify customers who bought more than 5 times

SELECT customerid, count(invoiceno) AS orders, ROUND(SUM(quantity)) AS amount
FROM orders
WHERE customerid IS NOT NULL
GROUP BY customerid
HAVING SUM(quantity) > 5;

-- - Distinguish new vs returning customers per month

WITH first_purchase AS (
    SELECT customerid, MIN(date) AS first_purchase
    FROM orders
    GROUP BY customerid
)
SELECT 
    DATE_TRUNC('month', o.date) AS month,
    COUNT(CASE WHEN o.date = f.first_purchase THEN 1 END) AS new_customers,
    COUNT(CASE WHEN o.date > f.first_purchase THEN 1 END) AS returning_customers
FROM orders o
JOIN first_purchase f
  ON o.customerid = f.customerid
GROUP BY DATE_TRUNC('month', o.date)
ORDER BY month;

-- Examine revenue patterns and top contributors:

-- - Top 10 products by revenue

SELECT * FROM orders;
SELECT invoiceno, ROUND(sum(quantity * unitprice)) AS revenue
FROM orders
GROUP BY invoiceno 
ORDER BY ROUND(sum(quantity * unitprice)) DESC
LIMIT 10;

-- - Top 10 customers by total spending

SELECT * FROM orders;
SELECT customerid, ROUND(sum(quantity * unitprice)) AS revenue
FROM orders
GROUP BY customerid 
ORDER BY ROUND(sum(quantity * unitprice)) DESC
LIMIT 10;

-- - Monthly revenue trends

SELECT * FROM orders;
SELECT * FROM products;

WITH ord AS (
    SELECT 
        DATE_TRUNC('month', o.date) AS month, 
        o.product_code,
        ROUND(SUM(o.quantity * o.unitprice)) AS revenue,
		RANK() OVER(PARTITION BY DATE_TRUNC('month', o.date) ORDER BY ROUND(SUM(o.quantity * o.unitprice)) DESC) AS rank
    FROM orders o
    GROUP BY DATE_TRUNC('month', o.date), o.product_code
)
SELECT 
    o.month,
    p.description, 
	o.product_code,
    o.revenue, 
	o.rank
FROM ord o
LEFT JOIN products p
    ON p.product_code = o.product_code
WHERE o.rank = 1
ORDER BY o.month, o.rank;

-- Understand churn and reactivation patterns:
-- - Find customers who haven’t ordered in the last 90 days (churned)

SELECT * FROM orders;
SELECT * FROM products;
SELECT * FROM customers;

WITH last_orders AS (
    SELECT customerid, MAX(date) AS last_purchase
    FROM orders
    GROUP BY customerid
)
SELECT c.customerid, l.last_purchase
FROM customers c
LEFT JOIN last_orders l
    ON c.customerid = l.customerid
WHERE l.last_purchase IS NULL          
   OR l.last_purchase <= DATE '2011-12-09' - INTERVAL '90 days';

-- - Perform cohort analysis (group by signup month)

SELECT 
    customerid,
    DATE_TRUNC('month', date) AS cohort_month
FROM customers;

-- Apply advanced SQL techniques for deeper insights:

-- - Use window functions to rank products by revenue each month

WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', o.date) AS month,
        p.product_code,
        p.description,
        SUM(o.quantity * o.unitprice) AS revenue
    FROM orders o
    JOIN products p
        ON o.product_code = p.product_code
    GROUP BY DATE_TRUNC('month', o.date), p.product_code, p.description
)
SELECT 
    month,
    product_code,
    description,
    revenue,
    RANK() OVER(PARTITION BY month ORDER BY revenue DESC) AS revenue_rank
FROM monthly_revenue
ORDER BY month, revenue_rank;

-- - Calculate running totals of revenue (cumulative sales)

SELECT 
    DATE_TRUNC('month', o.date) AS month,
    SUM(o.quantity * o.unitprice) AS monthly_revenue,
    SUM(SUM(o.quantity * o.unitprice)) OVER(ORDER BY DATE_TRUNC('month', o.date)) AS cumulative_revenue
FROM orders o
GROUP BY DATE_TRUNC('month', o.date)
ORDER BY month;
