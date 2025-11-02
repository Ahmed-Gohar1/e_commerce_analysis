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
-- 13. CUSTOMER PURCHASE FREQUENCY DISTRIBUTION
-- ====================
-- Question: How are customers distributed by purchase frequency?

WITH purchase_frequency AS (
    SELECT 
        customerid,
        COUNT(DISTINCT invoiceno) as purchase_count,
        ROUND(AVG(quantity * unitprice)) as avg_transaction_value
    FROM orders
    WHERE customerid IS NOT NULL
    GROUP BY customerid
),
frequency_buckets AS (
    SELECT 
        CASE 
            WHEN purchase_count = 1 THEN '1 order'
            WHEN purchase_count BETWEEN 2 AND 3 THEN '2-3 orders'
            WHEN purchase_count BETWEEN 4 AND 6 THEN '4-6 orders'
            WHEN purchase_count BETWEEN 7 AND 10 THEN '7-10 orders'
            ELSE '11+ orders'
        END as frequency_segment,
        COUNT(*) as customer_count,
        ROUND(AVG(avg_transaction_value)) as avg_value,
        ROUND(SUM(purchase_count * avg_transaction_value)) as segment_revenue
    FROM purchase_frequency
    GROUP BY 
        CASE 
            WHEN purchase_count = 1 THEN '1 order'
            WHEN purchase_count BETWEEN 2 AND 3 THEN '2-3 orders'
            WHEN purchase_count BETWEEN 4 AND 6 THEN '4-6 orders'
            WHEN purchase_count BETWEEN 7 AND 10 THEN '7-10 orders'
            ELSE '11+ orders'
        END
)
SELECT 
    frequency_segment,
    customer_count,
    avg_value,
    segment_revenue,
    ROUND(100.0 * customer_count / SUM(customer_count) OVER(), 1) as pct_of_customers,
    ROUND(100.0 * segment_revenue / SUM(segment_revenue) OVER(), 1) as pct_of_revenue
FROM frequency_buckets
ORDER BY 
    CASE frequency_segment
        WHEN '1 order' THEN 1
        WHEN '2-3 orders' THEN 2
        WHEN '4-6 orders' THEN 3
        WHEN '7-10 orders' THEN 4
        ELSE 5
    END;


-- ====================
-- 14. PRODUCT PERFORMANCE MATRIX
-- ====================
-- Question: Which products are high-volume vs high-value?

WITH product_metrics AS (
    SELECT 
        p.product_code,
        p.description,
        COUNT(DISTINCT o.invoiceno) as times_sold,
        SUM(o.quantity) as total_units,
        ROUND(SUM(o.quantity * o.unitprice)) as total_revenue,
        ROUND(AVG(o.unitprice)) as avg_price,
        COUNT(DISTINCT o.customerid) as unique_customers
    FROM orders o
    JOIN products p ON o.product_code = p.product_code
    GROUP BY p.product_code, p.description
),
quartiles AS (
    SELECT 
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY total_units) as median_volume,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY avg_price) as median_price
    FROM product_metrics
)
SELECT 
    pm.product_code,
    pm.description,
    pm.times_sold,
    pm.total_units,
    pm.total_revenue,
    pm.avg_price,
    pm.unique_customers,
    CASE 
        WHEN pm.total_units >= q.median_volume AND pm.avg_price >= q.median_price THEN '⭐ High Volume, High Value'
        WHEN pm.total_units >= q.median_volume AND pm.avg_price < q.median_price THEN '📦 High Volume, Low Value'
        WHEN pm.total_units < q.median_volume AND pm.avg_price >= q.median_price THEN '💎 Low Volume, High Value'
        ELSE '⚠️ Low Volume, Low Value'
    END as product_category
FROM product_metrics pm
CROSS JOIN quartiles q
ORDER BY pm.total_revenue DESC
LIMIT 20;


-- ====================
-- 15. CUSTOMER RETENTION RATE BY COHORT
-- ====================
-- Question: What percentage of customers return each month after their first purchase?

WITH customer_first_purchase AS (
    SELECT 
        customerid,
        DATE_TRUNC('month', MIN(date)) as cohort_month
    FROM orders
    GROUP BY customerid
),
customer_activity AS (
    SELECT 
        o.customerid,
        cfp.cohort_month,
        DATE_TRUNC('month', o.date) as activity_month,
        EXTRACT(MONTH FROM AGE(DATE_TRUNC('month', o.date), cfp.cohort_month)) as months_since_first
    FROM orders o
    JOIN customer_first_purchase cfp ON o.customerid = cfp.customerid
),
cohort_retention AS (
    SELECT 
        cohort_month,
        months_since_first,
        COUNT(DISTINCT customerid) as active_customers
    FROM customer_activity
    GROUP BY cohort_month, months_since_first
),
cohort_sizes AS (
    SELECT 
        cohort_month,
        COUNT(*) as cohort_size
    FROM customer_first_purchase
    GROUP BY cohort_month
)
SELECT 
    cr.cohort_month,
    cr.months_since_first as month_number,
    cr.active_customers,
    cs.cohort_size,
    ROUND(100.0 * cr.active_customers / cs.cohort_size, 1) as retention_rate
FROM cohort_retention cr
JOIN cohort_sizes cs ON cr.cohort_month = cs.cohort_month
WHERE cr.months_since_first <= 6
ORDER BY cr.cohort_month, cr.months_since_first;


-- ====================
-- 16. DAY OF WEEK & TIME ANALYSIS
-- ====================
-- Question: When do customers prefer to shop?

WITH order_timing AS (
    SELECT 
        customerid,
        invoiceno,
        date,
        EXTRACT(DOW FROM date) as day_of_week,
        EXTRACT(HOUR FROM date) as hour_of_day,
        quantity * unitprice as order_value
    FROM orders
    WHERE date IS NOT NULL
),
day_patterns AS (
    SELECT 
        CASE day_of_week
            WHEN 0 THEN 'Sunday'
            WHEN 1 THEN 'Monday'
            WHEN 2 THEN 'Tuesday'
            WHEN 3 THEN 'Wednesday'
            WHEN 4 THEN 'Thursday'
            WHEN 5 THEN 'Friday'
            WHEN 6 THEN 'Saturday'
        END as day_name,
        day_of_week,
        COUNT(DISTINCT invoiceno) as order_count,
        COUNT(DISTINCT customerid) as customer_count,
        ROUND(AVG(order_value)) as avg_order_value,
        ROUND(SUM(order_value)) as total_revenue
    FROM order_timing
    GROUP BY day_of_week
)
SELECT 
    day_name,
    order_count,
    customer_count,
    avg_order_value,
    total_revenue,
    ROUND(100.0 * order_count / SUM(order_count) OVER(), 1) as pct_of_orders
FROM day_patterns
ORDER BY day_of_week;


-- ====================
-- 17. PRODUCT AFFINITY ANALYSIS
-- ====================
-- Question: Which products are frequently bought together?

WITH product_pairs AS (
    SELECT 
        o1.invoiceno,
        o1.product_code as product_a,
        o2.product_code as product_b,
        o1.customerid
    FROM orders o1
    JOIN orders o2 
        ON o1.invoiceno = o2.invoiceno 
        AND o1.product_code < o2.product_code
),
pair_frequency AS (
    SELECT 
        product_a,
        product_b,
        COUNT(DISTINCT invoiceno) as times_bought_together,
        COUNT(DISTINCT customerid) as unique_customers
    FROM product_pairs
    GROUP BY product_a, product_b
    HAVING COUNT(DISTINCT invoiceno) >= 5
)
SELECT 
    pf.product_a,
    pa.description as product_a_name,
    pf.product_b,
    pb.description as product_b_name,
    pf.times_bought_together,
    pf.unique_customers
FROM pair_frequency pf
LEFT JOIN products pa ON pf.product_a = pa.product_code
LEFT JOIN products pb ON pf.product_b = pb.product_code
ORDER BY pf.times_bought_together DESC
LIMIT 15;


-- ====================
-- 18. CUSTOMER VALUE SEGMENTATION (RFM MODEL)
-- ====================
-- Question: How do we segment customers by Recency, Frequency, Monetary value?

WITH customer_rfm AS (
    SELECT 
        customerid,
        MAX(date) as last_purchase_date,
        COUNT(DISTINCT invoiceno) as purchase_frequency,
        ROUND(SUM(quantity * unitprice)) as monetary_value,
        DATE '2011-12-09' - MAX(date) as days_since_purchase
    FROM orders
    WHERE customerid IS NOT NULL
    GROUP BY customerid
),
rfm_scores AS (
    SELECT 
        customerid,
        days_since_purchase,
        purchase_frequency,
        monetary_value,
        NTILE(5) OVER (ORDER BY days_since_purchase ASC) as recency_score,
        NTILE(5) OVER (ORDER BY purchase_frequency DESC) as frequency_score,
        NTILE(5) OVER (ORDER BY monetary_value DESC) as monetary_score
    FROM customer_rfm
),
rfm_segments AS (
    SELECT 
        *,
        ROUND((recency_score + frequency_score + monetary_score) / 3.0, 1) as rfm_avg,
        CASE 
            WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN '🏆 Champions'
            WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score >= 3 THEN '⭐ Loyal Customers'
            WHEN recency_score >= 4 AND frequency_score <= 2 THEN '🆕 New Customers'
            WHEN recency_score <= 2 AND frequency_score >= 3 THEN '💤 At Risk'
            WHEN recency_score <= 2 AND frequency_score <= 2 THEN '😴 Lost'
            ELSE '🔄 Potential'
        END as customer_segment
    FROM rfm_scores
)
SELECT 
    customer_segment,
    COUNT(*) as customer_count,
    ROUND(AVG(days_since_purchase)) as avg_days_since_purchase,
    ROUND(AVG(purchase_frequency)) as avg_frequency,
    ROUND(AVG(monetary_value)) as avg_monetary_value,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 1) as pct_of_customers
FROM rfm_segments
GROUP BY customer_segment
ORDER BY avg_monetary_value DESC;


-- ====================
-- 19. SEASONAL TREND ANALYSIS
-- ====================
-- Question: How do sales vary by season and quarter?

WITH seasonal_sales AS (
    SELECT 
        DATE_TRUNC('quarter', date) as quarter,
        EXTRACT(QUARTER FROM date) as quarter_num,
        EXTRACT(YEAR FROM date) as year,
        CASE EXTRACT(QUARTER FROM date)
            WHEN 1 THEN 'Q1 - Winter'
            WHEN 2 THEN 'Q2 - Spring'
            WHEN 3 THEN 'Q3 - Summer'
            WHEN 4 THEN 'Q4 - Fall'
        END as season,
        COUNT(DISTINCT invoiceno) as total_orders,
        COUNT(DISTINCT customerid) as unique_customers,
        ROUND(SUM(quantity * unitprice)) as revenue,
        ROUND(AVG(quantity * unitprice)) as avg_order_value
    FROM orders
    GROUP BY 
        DATE_TRUNC('quarter', date),
        EXTRACT(QUARTER FROM date),
        EXTRACT(YEAR FROM date)
),
seasonal_comparison AS (
    SELECT 
        *,
        LAG(revenue) OVER (ORDER BY quarter) as prev_quarter_revenue,
        AVG(revenue) OVER () as overall_avg_revenue
    FROM seasonal_sales
)
SELECT 
    year,
    quarter_num,
    season,
    total_orders,
    unique_customers,
    revenue,
    avg_order_value,
    CASE 
        WHEN prev_quarter_revenue IS NOT NULL 
        THEN ROUND(100.0 * (revenue - prev_quarter_revenue) / prev_quarter_revenue, 1)
        ELSE NULL
    END as qoq_growth_pct,
    ROUND(100.0 * (revenue - overall_avg_revenue) / overall_avg_revenue, 1) as vs_avg_pct
FROM seasonal_comparison
ORDER BY quarter;


-- ====================
-- 20. AVERAGE ORDER SIZE DISTRIBUTION
-- ====================
-- Question: What's the distribution of order sizes?

WITH order_sizes AS (
    SELECT 
        invoiceno,
        customerid,
        date,
        ROUND(SUM(quantity * unitprice)) as order_total,
        SUM(quantity) as total_items
    FROM orders
    GROUP BY invoiceno, customerid, date
),
size_buckets AS (
    SELECT 
        CASE 
            WHEN order_total < 10 THEN 'Under $10'
            WHEN order_total < 50 THEN '$10-50'
            WHEN order_total < 100 THEN '$50-100'
            WHEN order_total < 250 THEN '$100-250'
            WHEN order_total < 500 THEN '$250-500'
            ELSE '$500+'
        END as order_size_range,
        COUNT(*) as order_count,
        ROUND(AVG(order_total)) as avg_order_value,
        ROUND(AVG(total_items)) as avg_items_per_order
    FROM order_sizes
    WHERE order_total > 0
    GROUP BY 
        CASE 
            WHEN order_total < 10 THEN 'Under $10'
            WHEN order_total < 50 THEN '$10-50'
            WHEN order_total < 100 THEN '$50-100'
            WHEN order_total < 250 THEN '$100-250'
            WHEN order_total < 500 THEN '$250-500'
            ELSE '$500+'
        END
)
SELECT 
    order_size_range,
    order_count,
    avg_order_value,
    avg_items_per_order,
    ROUND(100.0 * order_count / SUM(order_count) OVER(), 1) as pct_of_orders
FROM size_buckets
ORDER BY 
    CASE order_size_range
        WHEN 'Under $10' THEN 1
        WHEN '$10-50' THEN 2
        WHEN '$50-100' THEN 3
        WHEN '$100-250' THEN 4
        WHEN '$250-500' THEN 5
        ELSE 6
    END;


/*
=============================================================================
💡 ADVANCED SQL TECHNIQUES DEMONSTRATED
=============================================================================

✅ CTEs (Common Table Expressions) - Clean, readable query structure
✅ Window Functions - RANK(), LAG(), NTILE(), SUM() OVER()
✅ Date Functions - DATE_TRUNC(), EXTRACT(), AGE(), intervals
✅ Aggregate Functions - SUM(), AVG(), COUNT(), PERCENTILE_CONT()
✅ CASE Statements - Complex conditional logic
✅ Self-Joins - Product affinity analysis
✅ Subqueries - Nested data analysis
✅ String Functions - Formatting and display
✅ Statistical Analysis - Quartiles, distributions, RFM segmentation

=============================================================================
💡 TIPS FOR USING THESE QUERIES IN INTERVIEWS
=============================================================================

1. ALWAYS EXPLAIN THE BUSINESS QUESTION FIRST
   "This RFM segmentation helps identify our most valuable customers"

2. WALK THROUGH YOUR CTEs STEP BY STEP
   "First CTE calculates customer metrics, second assigns scores,
   third categorizes into business segments"

3. HIGHLIGHT ADVANCED TECHNIQUES
   "I use NTILE(5) to create quintile scores for RFM analysis"
   "Product affinity uses a self-join to find items bought together"

4. DISCUSS REAL-WORLD APPLICATIONS
   "Retention cohorts help predict customer lifetime value"
   "Seasonal analysis guides inventory planning"

5. EXPLAIN PERFORMANCE CONSIDERATIONS
   "CTEs are optimized by the query planner and more readable than subqueries"
   "I filter early in CTEs to reduce data processed in later steps"

6. MENTION BUSINESS IMPACT
   "The RFM model identifies at-risk customers worth $XX in potential revenue"
   "Product affinity drives cross-sell recommendations"

=============================================================================
*/
