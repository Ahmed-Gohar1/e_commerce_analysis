/*
=============================================================================
📦 E-Commerce Database - Schema Setup & Data Cleaning
=============================================================================
Creates tables, cleans data, and normalizes the schema.
Perfect for demonstrating database design skills!

Author: Ahmed Gohar
Date: November 2025
=============================================================================
*/

-- ====================
-- STEP 1: CREATE RAW DATA TABLE
-- ====================
-- Question: How do we store the raw e-commerce data?

CREATE TABLE e_comerce (
    InvoiceNo   VARCHAR(25),
    StockCode   VARCHAR(25),
    Description VARCHAR(65),
    Quantity    DECIMAL(10,2),
    InvoiceDate TIMESTAMP,
    UnitPrice   DECIMAL(10,2),
    CustomerID  VARCHAR(25),
    Country     VARCHAR(25)
);

-- Add primary key for unique row identification
ALTER TABLE e_comerce
ADD COLUMN id SERIAL PRIMARY KEY;


-- ====================
-- STEP 2: CLEAN & TRANSFORM DATA
-- ====================
-- Question: How do we split datetime into separate date and time columns?

-- Add new columns for date and time
ALTER TABLE e_comerce
ADD COLUMN date_only DATE,
ADD COLUMN time_only TIME;

-- Split the timestamp
UPDATE e_comerce
SET date_only = CAST(InvoiceDate AS DATE),
    time_only = CAST(InvoiceDate AS TIME);

-- Remove the original timestamp column
ALTER TABLE e_comerce
DROP COLUMN InvoiceDate;

-- Rename columns for clarity
ALTER TABLE e_comerce RENAME COLUMN InvoiceNo TO invoice;
ALTER TABLE e_comerce RENAME COLUMN StockCode TO product_code;
ALTER TABLE e_comerce RENAME COLUMN date_only TO date;
ALTER TABLE e_comerce RENAME COLUMN time_only TO time;


-- ====================
-- STEP 3: CREATE NORMALIZED TABLES
-- ====================
-- Question: How do we normalize this into a proper relational database?

-- Customers Table
CREATE TABLE customers (
    CustomerID VARCHAR(25) PRIMARY KEY,
    Country    VARCHAR(25),
    date       DATE
);

-- Products Table
CREATE TABLE products (
    product_code VARCHAR(25) PRIMARY KEY,
    Description  VARCHAR(65),
    UnitPrice    DECIMAL(10,2)
);

-- Orders Table
CREATE TABLE orders (
    InvoiceNo    VARCHAR(25) PRIMARY KEY,
    date         DATE,
    CustomerID   VARCHAR(25),
    product_code VARCHAR(25),
    Quantity     DECIMAL(10,2),
    UnitPrice    DECIMAL(10,2)
);


-- ====================
-- STEP 4: INSERT DATA INTO NORMALIZED TABLES
-- ====================

-- Insert customers (distinct only)
INSERT INTO customers (CustomerID, Country, date)
SELECT DISTINCT ON (CustomerID) CustomerID, Country, date
FROM e_comerce
WHERE CustomerID IS NOT NULL
ON CONFLICT (CustomerID) DO NOTHING;

-- Insert products (distinct only)
INSERT INTO products (product_code, Description, UnitPrice)
SELECT DISTINCT ON (product_code) product_code, Description, UnitPrice
FROM e_comerce
ON CONFLICT (product_code) DO NOTHING;

-- Insert orders
INSERT INTO orders (InvoiceNo, date, CustomerID, product_code, Quantity, UnitPrice)
SELECT invoice, date, CustomerID, product_code, Quantity, UnitPrice
FROM e_comerce
ON CONFLICT (InvoiceNo) DO NOTHING;


-- ====================
-- STEP 5: ADD FOREIGN KEY CONSTRAINTS
-- ====================
-- Question: How do we ensure data integrity across tables?

-- Orders foreign keys
ALTER TABLE orders
ADD CONSTRAINT fk_customer
FOREIGN KEY (CustomerID)
REFERENCES customers(CustomerID);

ALTER TABLE orders
ADD CONSTRAINT fk_product
FOREIGN KEY (product_code)
REFERENCES products(product_code);

-- E_comerce table foreign keys (for reference)
ALTER TABLE e_comerce
ADD CONSTRAINT fk_invoices
FOREIGN KEY (invoice)
REFERENCES orders(InvoiceNo);

ALTER TABLE e_comerce
ADD CONSTRAINT fk_stockcode
FOREIGN KEY (product_code)
REFERENCES products(product_code);

ALTER TABLE e_comerce
ADD CONSTRAINT fk_customerid
FOREIGN KEY (CustomerID)
REFERENCES customers(CustomerID);


/*
=============================================================================
💡 DATABASE DESIGN PRINCIPLES DEMONSTRATED
=============================================================================

1. NORMALIZATION: Reduced redundancy by separating customers, products, orders
2. DATA INTEGRITY: Foreign keys ensure valid references
3. DATA CLEANING: Split datetime, renamed columns for clarity
4. IDEMPOTENCY: Used ON CONFLICT to prevent duplicate inserts
5. PRIMARY KEYS: Every table has a unique identifier

This schema follows 3NF (Third Normal Form) best practices!
=============================================================================
*/


-- ====================
-- STEP 6: DATA QUALITY CHECKS & EDA
-- ====================
-- Question: How do we validate our data quality?

-- Check for NULL values in critical fields
SELECT 
    'customers' as table_name,
    COUNT(*) as total_rows,
    COUNT(*) - COUNT(customerid) as null_customerid,
    COUNT(*) - COUNT(country) as null_country
FROM customers

UNION ALL

SELECT 
    'products' as table_name,
    COUNT(*) as total_rows,
    COUNT(*) - COUNT(product_code) as null_product_code,
    COUNT(*) - COUNT(description) as null_description
FROM products

UNION ALL

SELECT 
    'orders' as table_name,
    COUNT(*) as total_rows,
    COUNT(*) - COUNT(invoiceno) as null_invoiceno,
    COUNT(*) - COUNT(customerid) as null_customerid
FROM orders;


-- Check for duplicate records
WITH duplicate_check AS (
    SELECT 
        invoiceno,
        COUNT(*) as occurrence_count
    FROM orders
    GROUP BY invoiceno
    HAVING COUNT(*) > 1
)
SELECT 
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ No duplicates found'
        ELSE '⚠️ ' || COUNT(*) || ' duplicate invoices found'
    END as duplicate_status
FROM duplicate_check;


-- Data distribution statistics
WITH order_stats AS (
    SELECT 
        MIN(quantity * unitprice) as min_order_value,
        MAX(quantity * unitprice) as max_order_value,
        ROUND(AVG(quantity * unitprice), 2) as avg_order_value,
        ROUND(STDDEV(quantity * unitprice), 2) as stddev_order_value,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY quantity * unitprice) as median_order_value
    FROM orders
)
SELECT 
    'Order Value Statistics' as metric_category,
    min_order_value,
    max_order_value,
    avg_order_value,
    median_order_value,
    stddev_order_value
FROM order_stats;


-- Customer geographic distribution
SELECT 
    country,
    COUNT(DISTINCT customerid) as customer_count,
    ROUND(100.0 * COUNT(DISTINCT customerid) / SUM(COUNT(DISTINCT customerid)) OVER(), 2) as pct_of_customers
FROM customers
GROUP BY country
ORDER BY customer_count DESC
LIMIT 10;


-- Product price range analysis
SELECT 
    CASE 
        WHEN unitprice < 5 THEN 'Budget ($0-5)'
        WHEN unitprice < 15 THEN 'Low ($5-15)'
        WHEN unitprice < 30 THEN 'Medium ($15-30)'
        WHEN unitprice < 50 THEN 'High ($30-50)'
        ELSE 'Premium ($50+)'
    END as price_range,
    COUNT(*) as product_count,
    ROUND(AVG(unitprice), 2) as avg_price,
    MIN(unitprice) as min_price,
    MAX(unitprice) as max_price
FROM products
GROUP BY 
    CASE 
        WHEN unitprice < 5 THEN 'Budget ($0-5)'
        WHEN unitprice < 15 THEN 'Low ($5-15)'
        WHEN unitprice < 30 THEN 'Medium ($15-30)'
        WHEN unitprice < 50 THEN 'High ($30-50)'
        ELSE 'Premium ($50+)'
    END
ORDER BY avg_price;


-- Temporal data coverage
SELECT 
    MIN(date) as earliest_order,
    MAX(date) as latest_order,
    MAX(date) - MIN(date) as days_of_data,
    COUNT(DISTINCT DATE_TRUNC('month', date)) as months_of_data
FROM orders;


/*
=============================================================================
📊 DATA QUALITY CHECKLIST
=============================================================================

✅ Check for NULL values in primary keys
✅ Identify duplicate records
✅ Calculate statistical distributions (mean, median, std dev)
✅ Analyze geographic distribution
✅ Examine price ranges
✅ Verify temporal coverage
✅ Validate foreign key relationships

These checks ensure your data is clean and ready for analysis!
=============================================================================
*/
