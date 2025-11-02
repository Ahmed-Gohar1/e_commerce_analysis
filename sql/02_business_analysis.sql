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


-- ====================
-- 13. CUSTOMER PURCHASE FREQUENCY
-- ====================
-- Question: How many times do customers typically buy?

WITH customer_purchases AS (
    SELECT 
        customerid,
        COUNT(DISTINCT invoiceno) as times_ordered
    FROM orders
    WHERE customerid IS NOT NULL
    GROUP BY customerid
)
SELECT 
    CASE 
        WHEN times_ordered = 1 THEN '1 order'
        WHEN times_ordered BETWEEN 2 AND 3 THEN '2-3 orders'
        WHEN times_ordered BETWEEN 4 AND 6 THEN '4-6 orders'
        WHEN times_ordered BETWEEN 7 AND 10 THEN '7-10 orders'
        ELSE '11+ orders'
    END as frequency_group,
    COUNT(*) as how_many_customers
FROM customer_purchases
GROUP BY 
    CASE 
        WHEN times_ordered = 1 THEN '1 order'
        WHEN times_ordered BETWEEN 2 AND 3 THEN '2-3 orders'
        WHEN times_ordered BETWEEN 4 AND 6 THEN '4-6 orders'
        WHEN times_ordered BETWEEN 7 AND 10 THEN '7-10 orders'
        ELSE '11+ orders'
    END
ORDER BY 
    CASE 
        WHEN times_ordered = 1 THEN 1
        WHEN times_ordered BETWEEN 2 AND 3 THEN 2
        WHEN times_ordered BETWEEN 4 AND 6 THEN 3
        WHEN times_ordered BETWEEN 7 AND 10 THEN 4
        ELSE 5
    END;


-- ====================
-- 14. HIGH VALUE VS HIGH VOLUME PRODUCTS
-- ====================
-- Question: Which products sell a lot vs make more money?

WITH product_stats AS (
    SELECT 
        p.product_code,
        p.description,
        SUM(o.quantity) as total_sold,
        ROUND(SUM(o.quantity * o.unitprice)) as total_revenue
    FROM orders o
    JOIN products p ON o.product_code = p.product_code
    GROUP BY p.product_code, p.description
)
SELECT 
    product_code,
    description,
    total_sold,
    total_revenue,
    CASE 
        WHEN total_sold > 500 AND total_revenue > 10000 THEN '⭐ Best Seller + High Revenue'
        WHEN total_sold > 500 THEN '📦 Best Seller'
        WHEN total_revenue > 10000 THEN '💎 High Revenue'
        ELSE '📊 Regular Product'
    END as product_type
FROM product_stats
ORDER BY total_revenue DESC
LIMIT 20;


-- ====================
-- 15. CUSTOMER RETENTION BY MONTH
-- ====================
-- Question: Do customers come back after their first purchase?

WITH first_orders AS (
    SELECT 
        customerid,
        MIN(date) as first_purchase_date
    FROM orders
    GROUP BY customerid
),
repeat_orders AS (
    SELECT 
        o.customerid,
        f.first_purchase_date,
        COUNT(DISTINCT o.invoiceno) - 1 as repeat_purchases
    FROM orders o
    JOIN first_orders f ON o.customerid = f.customerid
    GROUP BY o.customerid, f.first_purchase_date
)
SELECT 
    CASE 
        WHEN repeat_purchases = 0 THEN 'One-time buyer'
        WHEN repeat_purchases BETWEEN 1 AND 2 THEN 'Bought 2-3 times'
        WHEN repeat_purchases BETWEEN 3 AND 5 THEN 'Bought 4-6 times'
        ELSE 'Frequent buyer (7+)'
    END as customer_type,
    COUNT(*) as number_of_customers
FROM repeat_orders
GROUP BY 
    CASE 
        WHEN repeat_purchases = 0 THEN 'One-time buyer'
        WHEN repeat_purchases BETWEEN 1 AND 2 THEN 'Bought 2-3 times'
        WHEN repeat_purchases BETWEEN 3 AND 5 THEN 'Bought 4-6 times'
        ELSE 'Frequent buyer (7+)'
    END
ORDER BY number_of_customers DESC;


-- ====================
-- 16. BEST DAY OF WEEK TO SHOP
-- ====================
-- Question: What day do most people shop?

WITH daily_sales AS (
    SELECT 
        CASE EXTRACT(DOW FROM date)
            WHEN 0 THEN 'Sunday'
            WHEN 1 THEN 'Monday'
            WHEN 2 THEN 'Tuesday'
            WHEN 3 THEN 'Wednesday'
            WHEN 4 THEN 'Thursday'
            WHEN 5 THEN 'Friday'
            WHEN 6 THEN 'Saturday'
        END as day_name,
        EXTRACT(DOW FROM date) as day_number,
        COUNT(DISTINCT invoiceno) as orders_count
    FROM orders
    WHERE date IS NOT NULL
    GROUP BY EXTRACT(DOW FROM date)
)
SELECT 
    day_name,
    orders_count
FROM daily_sales
ORDER BY day_number;


-- ====================
-- 17. PRODUCTS BOUGHT TOGETHER
-- ====================
-- Question: What products do people buy in the same order?

WITH same_order_products AS (
    SELECT 
        o1.invoiceno,
        o1.product_code as product_1,
        o2.product_code as product_2
    FROM orders o1
    JOIN orders o2 
        ON o1.invoiceno = o2.invoiceno 
        AND o1.product_code < o2.product_code
)
SELECT 
    product_1,
    product_2,
    COUNT(*) as times_bought_together
FROM same_order_products
GROUP BY product_1, product_2
HAVING COUNT(*) >= 10
ORDER BY times_bought_together DESC
LIMIT 10;


-- ====================
-- 18. CUSTOMER VALUE GROUPS (SIMPLE RFM)
-- ====================
-- Question: Who are our best customers?

WITH customer_info AS (
    SELECT 
        customerid,
        MAX(date) as last_order,
        COUNT(DISTINCT invoiceno) as total_orders,
        ROUND(SUM(quantity * unitprice)) as total_spent
    FROM orders
    WHERE customerid IS NOT NULL
    GROUP BY customerid
)
SELECT 
    CASE 
        WHEN total_orders >= 10 AND total_spent >= 5000 THEN '🏆 VIP Customer'
        WHEN total_orders >= 5 AND total_spent >= 2000 THEN '⭐ Good Customer'
        WHEN total_orders >= 3 THEN '👍 Regular Customer'
        ELSE '🆕 New/Occasional Customer'
    END as customer_category,
    COUNT(*) as number_of_customers,
    ROUND(AVG(total_spent)) as avg_spent
FROM customer_info
GROUP BY 
    CASE 
        WHEN total_orders >= 10 AND total_spent >= 5000 THEN '🏆 VIP Customer'
        WHEN total_orders >= 5 AND total_spent >= 2000 THEN '⭐ Good Customer'
        WHEN total_orders >= 3 THEN '� Regular Customer'
        ELSE '🆕 New/Occasional Customer'
    END
ORDER BY avg_spent DESC;


-- ====================
-- 19. SALES BY SEASON
-- ====================
-- Question: Which season has the most sales?

WITH seasonal_data AS (
    SELECT 
        EXTRACT(YEAR FROM date) as year,
        CASE EXTRACT(QUARTER FROM date)
            WHEN 1 THEN 'Q1 - Winter'
            WHEN 2 THEN 'Q2 - Spring'
            WHEN 3 THEN 'Q3 - Summer'
            WHEN 4 THEN 'Q4 - Fall'
        END as season,
        COUNT(DISTINCT invoiceno) as total_orders,
        ROUND(SUM(quantity * unitprice)) as total_revenue
    FROM orders
    GROUP BY EXTRACT(YEAR FROM date), EXTRACT(QUARTER FROM date)
)
SELECT 
    year,
    season,
    total_orders,
    total_revenue
FROM seasonal_data
ORDER BY year, 
    CASE season
        WHEN 'Q1 - Winter' THEN 1
        WHEN 'Q2 - Spring' THEN 2
        WHEN 'Q3 - Summer' THEN 3
        WHEN 'Q4 - Fall' THEN 4
    END;


-- ====================
-- 20. ORDER SIZE CATEGORIES
-- ====================
-- Question: Are most orders small or large?

WITH order_totals AS (
    SELECT 
        invoiceno,
        ROUND(SUM(quantity * unitprice)) as order_amount
    FROM orders
    GROUP BY invoiceno
)
SELECT 
    CASE 
        WHEN order_amount < 10 THEN 'Small (Under $10)'
        WHEN order_amount < 50 THEN 'Medium ($10-50)'
        WHEN order_amount < 100 THEN 'Large ($50-100)'
        ELSE 'Extra Large ($100+)'
    END as order_size,
    COUNT(*) as number_of_orders
FROM order_totals
WHERE order_amount > 0
GROUP BY 
    CASE 
        WHEN order_amount < 10 THEN 'Small (Under $10)'
        WHEN order_amount < 50 THEN 'Medium ($10-50)'
        WHEN order_amount < 100 THEN 'Large ($50-100)'
        ELSE 'Extra Large ($100+)'
    END
ORDER BY 
    CASE 
        WHEN order_amount < 10 THEN 1
        WHEN order_amount < 50 THEN 2
        WHEN order_amount < 100 THEN 3
        ELSE 4
    END;


/*
=============================================================================
💡 SIMPLE BUT POWERFUL SQL TECHNIQUES
=============================================================================

✅ CTEs (WITH clauses) - Break down queries into easy steps
✅ CASE Statements - Create categories and groups
✅ COUNT & SUM - Basic counting and totals
✅ GROUP BY - Organize data into groups
✅ Joins - Connect tables together
✅ Date Functions - EXTRACT for day/year/quarter
✅ Aggregations - COUNT, SUM, AVG, ROUND

=============================================================================
💡 TIPS FOR EXPLAINING THESE QUERIES IN INTERVIEWS
=============================================================================

1. START WITH THE BUSINESS QUESTION
   "This query helps us understand which customers buy the most"

2. EXPLAIN THE CTE FIRST
   "First, I create a CTE that counts orders per customer"

3. THEN EXPLAIN THE MAIN QUERY
   "Then I group them into categories like VIP, Regular, and New customers"

4. MENTION REAL-WORLD USE
   "This helps the marketing team target the right customers"

5. KEEP IT SIMPLE
   "I use CTEs to make the code easy to read and understand"

REMEMBER: Simple code that works is better than complex code that's hard to understand!

=============================================================================
*/
