# e_comerce_analysis – Database & SQL Analytics

## Overview

This project demonstrates the process of **cleaning, normalizing, and analyzing e-commerce sales data** using SQL. It starts from a raw table (`e_comerce`), transforms and splits columns, normalizes the schema into analytical tables (`customers`, `products`, `orders`), and finally provides a set of advanced SQL queries to extract business insights.

---

## Table of Contents

- [Schema Design & Normalization](#schema-design--normalization)
  - [Original Table Creation](#original-table-creation)
  - [Cleaning & Transformation](#cleaning--transformation)
  - [Entity Identification & Normalization](#entity-identification--normalization)
  - [Data Insertion](#data-insertion)
  - [Foreign Key Constraints](#foreign-key-constraints)
- [SQL Analytics](#sql-analytics)
  - [High-Level Business Metrics](#high-level-business-metrics)
  - [Customer Behavior Analysis](#customer-behavior-analysis)
  - [Revenue & Product Analysis](#revenue--product-analysis)
  - [Churn & Cohort Analysis](#churn--cohort-analysis)
  - [Advanced SQL Techniques](#advanced-sql-techniques)
- [Usage](#usage)
- [Notes](#notes)

---

## Schema Design & Normalization

### Original Table Creation

```sql
CREATE TABLE e_comerce (
    InvoiceNo   VARCHAR(25),
    StockCode   VARCHAR(25), -- fk
    Description VARCHAR(65),
    Quantity    DECIMAL(10,2),
    InvoiceDate TIMESTAMP,
    UnitPrice   DECIMAL(10,2),
    CustomerID  VARCHAR(25), -- fk
    Country     VARCHAR(25)
);

ALTER TABLE e_comerce ADD COLUMN id SERIAL PRIMARY KEY;
```

### Cleaning & Transformation

- **Splitting Date and Time:**

```sql
ALTER TABLE e_comerce ADD COLUMN date_only DATE, ADD COLUMN time_only TIME;
UPDATE e_comerce
SET date_only = CAST(InvoiceDate AS DATE),
    time_only = CAST(InvoiceDate AS TIME);
ALTER TABLE e_comerce DROP COLUMN InvoiceDate;
```

- **Renaming Columns for Clarity:**

```sql
ALTER TABLE e_comerce RENAME COLUMN InvoiceNo TO invoice;
ALTER TABLE e_comerce RENAME COLUMN StockCode TO product_code;
ALTER TABLE e_comerce RENAME COLUMN date_only TO date;
ALTER TABLE e_comerce RENAME COLUMN time_only TO time;
```

### Entity Identification & Normalization

- **Customers**

```sql
CREATE TABLE customers(
    CustomerID  VARCHAR(25) PRIMARY KEY,
    Country     VARCHAR(25),
    date        DATE
);
```

- **Products**

```sql
CREATE TABLE products(
    product_code VARCHAR(25) PRIMARY KEY,
    Description  VARCHAR(65),
    UnitPrice    DECIMAL(10,2)
);
```

- **Orders**

```sql
CREATE TABLE orders(
    InvoiceNo    VARCHAR(25) PRIMARY KEY,
    date         DATE,
    CustomerID   VARCHAR(25), -- fk
    product_code VARCHAR(25), -- fk
    Quantity     DECIMAL(10,2),
    UnitPrice    DECIMAL(10,2)
);
```

### Data Insertion

- **Customers**

```sql
INSERT INTO customers (CustomerID, Country, date)
SELECT DISTINCT ON (CustomerID) CustomerID, Country, date
FROM e_comerce
WHERE CustomerID IS NOT NULL
ON CONFLICT (CustomerID) DO NOTHING;
```

- **Products**

```sql
INSERT INTO products (product_code, Description, UnitPrice)
SELECT DISTINCT ON (product_code) product_code, Description, UnitPrice
FROM e_comerce
ON CONFLICT (product_code) DO NOTHING;
```

- **Orders**

```sql
INSERT INTO orders (InvoiceNo, date, CustomerID, product_code, Quantity, UnitPrice)
SELECT invoice, date, CustomerID, product_code, Quantity, UnitPrice
FROM e_comerce
ON CONFLICT (InvoiceNo) DO NOTHING;
```

### Foreign Key Constraints

```sql
ALTER TABLE orders
    ADD CONSTRAINT fk_customer FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID),
    ADD CONSTRAINT fk_product FOREIGN KEY (product_code) REFERENCES products(product_code);

ALTER TABLE e_comerce
    ADD CONSTRAINT fk_invoices FOREIGN KEY (invoice) REFERENCES orders(InvoiceNo),
    ADD CONSTRAINT fk_stockcode FOREIGN KEY (product_code) REFERENCES products(product_code),
    ADD CONSTRAINT fk_customerid FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID);
```

---

## SQL Analytics

### High-Level Business Metrics

- **Total number of customers**
    ```sql
    SELECT COUNT(DISTINCT customerid) FROM customers;
    ```

- **Total number of orders**
    ```sql
    SELECT COUNT(DISTINCT invoiceno) FROM orders;
    ```

- **Total revenue**
    ```sql
    SELECT ROUND(SUM(quantity * unitprice)) AS total_revenue FROM orders;
    ```

- **Average order value**
    ```sql
    SELECT ROUND(AVG(quantity * unitprice)) AS average_order_value FROM orders;
    ```

### Customer Behavior Analysis

- **Orders per customer**
    ```sql
    SELECT customerid, COUNT(invoiceno) AS orders
    FROM orders
    WHERE customerid IS NOT NULL
    GROUP BY customerid;
    ```

- **Customers who bought more than 5 times**
    ```sql
    SELECT customerid, COUNT(invoiceno) AS orders, ROUND(SUM(quantity)) AS amount
    FROM orders
    WHERE customerid IS NOT NULL
    GROUP BY customerid
    HAVING SUM(quantity) > 5;
    ```

- **New vs Returning customers per month**
    ```sql
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
    JOIN first_purchase f ON o.customerid = f.customerid
    GROUP BY DATE_TRUNC('month', o.date)
    ORDER BY month;
    ```

### Revenue & Product Analysis

- **Top 10 products by revenue**
    ```sql
    SELECT product_code, ROUND(SUM(quantity * unitprice)) AS revenue
    FROM orders
    GROUP BY product_code
    ORDER BY revenue DESC
    LIMIT 10;
    ```

- **Top 10 customers by total spending**
    ```sql
    SELECT customerid, ROUND(SUM(quantity * unitprice)) AS revenue
    FROM orders
    GROUP BY customerid
    ORDER BY revenue DESC
    LIMIT 10;
    ```

- **Monthly revenue trends (top product per month)**
    ```sql
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
    LEFT JOIN products p ON p.product_code = o.product_code
    WHERE o.rank = 1
    ORDER BY o.month, o.rank;
    ```

### Churn & Cohort Analysis

- **Customers who haven’t ordered in the last 90 days (churned)**
    ```sql
    WITH last_orders AS (
        SELECT customerid, MAX(date) AS last_purchase
        FROM orders
        GROUP BY customerid
    )
    SELECT c.customerid, l.last_purchase
    FROM customers c
    LEFT JOIN last_orders l ON c.customerid = l.customerid
    WHERE l.last_purchase IS NULL          
       OR l.last_purchase <= DATE '2011-12-09' - INTERVAL '90 days';
    ```

- **Cohort analysis (group by signup month)**
    ```sql
    SELECT 
        customerid,
        DATE_TRUNC('month', date) AS cohort_month
    FROM customers;
    ```

### Advanced SQL Techniques

- **Rank products by revenue each month**
    ```sql
    WITH monthly_revenue AS (
        SELECT 
            DATE_TRUNC('month', o.date) AS month,
            p.product_code,
            p.description,
            SUM(o.quantity * o.unitprice) AS revenue
        FROM orders o
        JOIN products p ON o.product_code = p.product_code
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
    ```

- **Running totals of revenue (cumulative sales)**
    ```sql
    SELECT 
        DATE_TRUNC('month', o.date) AS month,
        SUM(o.quantity * o.unitprice) AS monthly_revenue,
        SUM(SUM(o.quantity * o.unitprice)) OVER(ORDER BY DATE_TRUNC('month', o.date)) AS cumulative_revenue
    FROM orders o
    GROUP BY DATE_TRUNC('month', o.date)
    ORDER BY month;
    ```

---

## Usage

1. **Create and load the raw `e_comerce` table** using your initial sales data.
2. **Apply the provided SQL scripts step by step** to clean, transform, and normalize the data.
3. **Use the analytical queries** for business insights, reporting, and visualization.

---

## Notes

- Designed for PostgreSQL syntax.
- Suitable for e-commerce, retail, and sales analytics case studies.
- Supports analytics on customer behavior, revenue trends, product performance, and retention.

---

**Author:** Ahmed-Gohar1  
**Repo:** [e_commerce_analysis](https://github.com/Ahmed-Gohar1/e_commerce_analysis)
