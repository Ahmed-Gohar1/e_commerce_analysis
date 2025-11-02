/*
=============================================================================
📊 E-Commerce Analysis - Business Intelligence Queries
=============================================================================
Simple but powerful SQL queries to extract business insights.
Uses CTEs to keep code clean and interview-ready!

Author: Ahmed Gohar
Date: November 2025
=============================================================================
*/

-- ====================
-- 1. BUSINESS OVERVIEW
-- ====================
-- Question: What are our key business metrics?

WITH business_metrics AS (
    SELECT 
        COUNT(DISTINCT c.customerid) as total_customers,
        COUNT(DISTINCT o.invoiceno) as total_orders,
        ROUND(SUM(o.quantity * o.unitprice)) as total_revenue,
        ROUND(AVG(o.quantity * o.unitprice)) as avg_order_value
    FROM orders o
    LEFT JOIN customers c ON o.customerid = c.customerid
)
SELECT * FROM business_metrics;
-- Expected: ~4,372 customers, ~25,900 orders, ~$590K revenue, ~$23 avg order


-- ====================
-- 2. CUSTOMER ACTIVITY LEVELS
-- ====================
-- Question: How many orders does each customer make?

WITH customer_orders AS (
    SELECT 
        customerid,
        COUNT(invoiceno) as total_orders,
        ROUND(SUM(quantity)) as total_items,
        ROUND(SUM(quantity * unitprice)) as total_spent
    FROM orders
    WHERE customerid IS NOT NULL
    GROUP BY customerid
)
SELECT 
    customerid,
    total_orders,
    total_items,
    total_spent,
    CASE 
        WHEN total_orders >= 10 THEN 'VIP Customer'
        WHEN total_orders >= 5 THEN 'Regular Customer'
        ELSE 'Occasional Customer'
    END as customer_segment
FROM customer_orders
ORDER BY total_spent DESC;


-- ====================
-- 3. HIGH-VALUE CUSTOMERS
-- ====================
-- Question: Who are our top customers by spending?

WITH customer_spending AS (
    SELECT 
        customerid,
        COUNT(invoiceno) as orders,
        ROUND(SUM(quantity * unitprice)) as revenue
    FROM orders
    WHERE customerid IS NOT NULL
    GROUP BY customerid
)
SELECT 
    customerid,
    orders,
    revenue
FROM customer_spending
WHERE orders > 5
ORDER BY revenue DESC
LIMIT 20;


-- ====================
-- 4. NEW VS RETURNING CUSTOMERS
-- ====================
-- Question: Are we acquiring new customers or keeping existing ones?

WITH first_purchase AS (
    SELECT 
        customerid,
        MIN(date) as first_order_date
    FROM orders
    GROUP BY customerid
)
SELECT 
    DATE_TRUNC('month', o.date) AS month,
    COUNT(CASE WHEN o.date = f.first_order_date THEN 1 END) as new_customers,
    COUNT(CASE WHEN o.date > f.first_order_date THEN 1 END) as returning_customers
FROM orders o
JOIN first_purchase f ON o.customerid = f.customerid
GROUP BY DATE_TRUNC('month', o.date)
ORDER BY month;


-- ====================
-- 5. TOP REVENUE GENERATING ORDERS
-- ====================
-- Question: Which individual orders brought in the most money?

WITH order_revenue AS (
    SELECT 
        invoiceno,
        date,
        customerid,
        ROUND(SUM(quantity * unitprice)) as order_total
    FROM orders
    GROUP BY invoiceno, date, customerid
)
SELECT 
    invoiceno,
    date,
    customerid,
    order_total
FROM order_revenue
ORDER BY order_total DESC
LIMIT 10;


-- ====================
-- 6. TOP SPENDING CUSTOMERS
-- ====================
-- Question: Who are our best customers by lifetime value?

WITH customer_lifetime_value AS (
    SELECT 
        customerid,
        COUNT(DISTINCT invoiceno) as total_orders,
        ROUND(SUM(quantity * unitprice)) as lifetime_revenue
    FROM orders
    GROUP BY customerid
)
SELECT 
    customerid,
    total_orders,
    lifetime_revenue,
    ROUND(lifetime_revenue / total_orders) as avg_order_size
FROM customer_lifetime_value
ORDER BY lifetime_revenue DESC
LIMIT 10;


-- ====================
-- 7. MONTHLY REVENUE TRENDS
-- ====================
-- Question: How is our revenue trending over time?

WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', date) as month,
        ROUND(SUM(quantity * unitprice)) as revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', date)
),
revenue_with_growth AS (
    SELECT 
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) as previous_month
    FROM monthly_revenue
)
SELECT 
    month,
    revenue,
    previous_month,
    CASE 
        WHEN previous_month IS NOT NULL 
        THEN ROUND(100.0 * (revenue - previous_month) / previous_month, 1)
        ELSE NULL
    END as growth_percent
FROM revenue_with_growth
ORDER BY month;


-- ====================
-- 8. BEST SELLING PRODUCT EACH MONTH
-- ====================
-- Question: What's the #1 product every month?

WITH monthly_product_sales AS (
    SELECT 
        DATE_TRUNC('month', o.date) as month,
        o.product_code,
        ROUND(SUM(o.quantity * o.unitprice)) as revenue,
        RANK() OVER (
            PARTITION BY DATE_TRUNC('month', o.date) 
            ORDER BY ROUND(SUM(o.quantity * o.unitprice)) DESC
        ) as rank
    FROM orders o
    GROUP BY DATE_TRUNC('month', o.date), o.product_code
)
SELECT 
    m.month,
    m.product_code,
    p.description,
    m.revenue
FROM monthly_product_sales m
LEFT JOIN products p ON m.product_code = p.product_code
WHERE m.rank = 1
ORDER BY m.month;


-- ====================
-- 9. CHURNED CUSTOMERS
-- ====================
-- Question: Who hasn't ordered in the last 90 days?

WITH last_orders AS (
    SELECT 
        customerid,
        MAX(date) as last_purchase_date
    FROM orders
    GROUP BY customerid
)
SELECT 
    c.customerid,
    c.country,
    l.last_purchase_date,
    DATE '2011-12-09' - l.last_purchase_date as days_since_purchase
FROM customers c
LEFT JOIN last_orders l ON c.customerid = l.customerid
WHERE l.last_purchase_date IS NULL
   OR l.last_purchase_date <= DATE '2011-12-09' - INTERVAL '90 days'
ORDER BY days_since_purchase DESC;


-- ====================
-- 10. PRODUCT REVENUE RANKING BY MONTH
-- ====================
-- Question: How do products rank in terms of revenue each month?

WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', o.date) as month,
        p.product_code,
        p.description,
        ROUND(SUM(o.quantity * o.unitprice)) as revenue
    FROM orders o
    JOIN products p ON o.product_code = p.product_code
    GROUP BY DATE_TRUNC('month', o.date), p.product_code, p.description
)
SELECT 
    month,
    product_code,
    description,
    revenue,
    RANK() OVER (PARTITION BY month ORDER BY revenue DESC) as revenue_rank
FROM monthly_revenue
WHERE revenue > 0
ORDER BY month DESC, revenue_rank
LIMIT 50;


-- ====================
-- 11. CUMULATIVE REVENUE OVER TIME
-- ====================
-- Question: What's our running total of revenue?

WITH monthly_totals AS (
    SELECT 
        DATE_TRUNC('month', date) as month,
        ROUND(SUM(quantity * unitprice)) as monthly_revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', date)
)
SELECT 
    month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (ORDER BY month) as cumulative_revenue
FROM monthly_totals
ORDER BY month;


-- ====================
-- 12. CUSTOMER COHORT ANALYSIS
-- ====================
-- Question: Which month did each customer first join?

WITH customer_cohorts AS (
    SELECT 
        customerid,
        DATE_TRUNC('month', MIN(date)) as cohort_month,
        COUNT(DISTINCT invoiceno) as total_orders,
        ROUND(SUM(quantity * unitprice)) as total_revenue
    FROM orders
    GROUP BY customerid
)
SELECT 
    cohort_month,
    COUNT(customerid) as customers_in_cohort,
    SUM(total_orders) as cohort_total_orders,
    ROUND(AVG(total_revenue)) as avg_customer_value
FROM customer_cohorts
GROUP BY cohort_month
ORDER BY cohort_month;


/*
=============================================================================
💡 TIPS FOR USING THESE QUERIES IN INTERVIEWS
=============================================================================

1. ALWAYS EXPLAIN THE BUSINESS QUESTION FIRST
   "This query helps identify which customers are at risk of churning"

2. WALK THROUGH YOUR CTEs
   "I first create a CTE to find the last purchase date for each customer,
   then filter for those who haven't purchased in 90 days"

3. MENTION WINDOW FUNCTIONS
   "I use RANK() to identify the top product each month, partitioned by month"

4. DISCUSS REAL-WORLD APPLICATIONS
   "This cumulative revenue query helps track progress toward annual targets"

5. OPTIMIZE YOUR CODE
   "I use CTEs instead of subqueries for better readability and performance"

=============================================================================
*/
