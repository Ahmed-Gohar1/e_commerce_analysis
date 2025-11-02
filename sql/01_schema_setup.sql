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
