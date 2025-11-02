# 🛒 E-Commerce Sales Analysis![Database ERD](tabels.png)



![Database ERD](docs/database_schema.png)# e_comerce_analysis – Database & SQL Analytics



A comprehensive SQL-based e-commerce analytics project demonstrating **database design, data normalization, and business intelligence** using real-world transaction data.## Overview



---This project demonstrates the process of **cleaning, normalizing, and analyzing e-commerce sales data** using SQL. It starts from a raw table (`e_comerce`), transforms and splits columns, normalizes the schema into analytical tables (`customers`, `products`, `orders`), and finally provides a set of advanced SQL queries to extract business insights.



## 📋 Table of Contents---



- [Overview](#overview)## Table of Contents

- [Key Features](#key-features)

- [Database Schema](#database-schema)- [Schema Design & Normalization](#schema-design--normalization)

- [Project Structure](#project-structure)  - [Original Table Creation](#original-table-creation)

- [SQL Queries](#sql-queries)  - [Cleaning & Transformation](#cleaning--transformation)

- [Business Insights](#business-insights)  - [Entity Identification & Normalization](#entity-identification--normalization)

- [Technologies Used](#technologies-used)  - [Data Insertion](#data-insertion)

- [Getting Started](#getting-started)  - [Foreign Key Constraints](#foreign-key-constraints)

- [Key Learnings](#key-learnings)- [SQL Analytics](#sql-analytics)

- [Author](#author)  - [High-Level Business Metrics](#high-level-business-metrics)

- [License](#license)  - [Customer Behavior Analysis](#customer-behavior-analysis)

  - [Revenue & Product Analysis](#revenue--product-analysis)

---  - [Churn & Cohort Analysis](#churn--cohort-analysis)

  - [Advanced SQL Techniques](#advanced-sql-techniques)

## 🎯 Overview- [Usage](#usage)

- [Notes](#notes)

This project demonstrates the complete lifecycle of an e-commerce data analytics pipeline:

---

1. **Data Cleaning**: Transforming raw transaction data

2. **Database Normalization**: Designing a 3NF relational schema## Schema Design & Normalization

3. **Business Intelligence**: Extracting actionable insights with SQL

### Original Table Creation

**Perfect for showcasing:**

- Database design & normalization skills```sql

- Advanced SQL techniques (CTEs, window functions, joins)CREATE TABLE e_comerce (

- Business analysis & metrics calculation    InvoiceNo   VARCHAR(25),

- Data-driven decision making    StockCode   VARCHAR(25), -- fk

    Description VARCHAR(65),

---    Quantity    DECIMAL(10,2),

    InvoiceDate TIMESTAMP,

## ⭐ Key Features    UnitPrice   DECIMAL(10,2),

    CustomerID  VARCHAR(25), -- fk

### Database Design    Country     VARCHAR(25)

- ✅ **Normalized Schema**: Separated into customers, products, and orders tables);

- ✅ **Data Integrity**: Foreign key constraints ensure referential integrity

- ✅ **Clean Architecture**: Follows 3NF (Third Normal Form) principlesALTER TABLE e_comerce ADD COLUMN id SERIAL PRIMARY KEY;

```

### SQL Analysis

- 📊 **12 Business Intelligence Queries** with CTEs### Cleaning & Transformation

- 📈 **Customer Segmentation**: VIP, Regular, and Occasional customers

- 💰 **Revenue Analytics**: Trends, top products, best customers- **Splitting Date and Time:**

- 🔄 **Cohort Analysis**: Customer retention and churn patterns

- 📉 **Growth Metrics**: Month-over-month revenue tracking```sql

ALTER TABLE e_comerce ADD COLUMN date_only DATE, ADD COLUMN time_only TIME;

### Code QualityUPDATE e_comerce

- 🎯 **Beginner-Friendly**: Every query answers a clear business questionSET date_only = CAST(InvoiceDate AS DATE),

- 💡 **Interview-Ready**: Includes tips for explaining queries    time_only = CAST(InvoiceDate AS TIME);

- 📝 **Well-Documented**: Comments explain the "why" behind each queryALTER TABLE e_comerce DROP COLUMN InvoiceDate;

- 🧹 **Clean Code**: Uses CTEs for readability```



---- **Renaming Columns for Clarity:**



## 🗄️ Database Schema```sql

ALTER TABLE e_comerce RENAME COLUMN InvoiceNo TO invoice;

### Original Raw TableALTER TABLE e_comerce RENAME COLUMN StockCode TO product_code;

```sqlALTER TABLE e_comerce RENAME COLUMN date_only TO date;

e_comerce (ALTER TABLE e_comerce RENAME COLUMN time_only TO time;

    id SERIAL PRIMARY KEY,```

    invoice VARCHAR(25),

    product_code VARCHAR(25),### Entity Identification & Normalization

    description VARCHAR(65),

    quantity DECIMAL(10,2),- **Customers**

    date DATE,

    time TIME,```sql

    unitprice DECIMAL(10,2),CREATE TABLE customers(

    customerid VARCHAR(25),    CustomerID  VARCHAR(25) PRIMARY KEY,

    country VARCHAR(25)    Country     VARCHAR(25),

)    date        DATE

```);

```

### Normalized Tables

- **Products**

**Customers Table**

```sql```sql

customers (CREATE TABLE products(

    CustomerID VARCHAR(25) PRIMARY KEY,    product_code VARCHAR(25) PRIMARY KEY,

    Country VARCHAR(25),    Description  VARCHAR(65),

    date DATE    UnitPrice    DECIMAL(10,2)

));

``````



**Products Table**- **Orders**

```sql

products (```sql

    product_code VARCHAR(25) PRIMARY KEY,CREATE TABLE orders(

    Description VARCHAR(65),    InvoiceNo    VARCHAR(25) PRIMARY KEY,

    UnitPrice DECIMAL(10,2)    date         DATE,

)    CustomerID   VARCHAR(25), -- fk

```    product_code VARCHAR(25), -- fk

    Quantity     DECIMAL(10,2),

**Orders Table**    UnitPrice    DECIMAL(10,2)

```sql);

orders (```

    InvoiceNo VARCHAR(25) PRIMARY KEY,

    date DATE,### Data Insertion

    CustomerID VARCHAR(25) REFERENCES customers(CustomerID),

    product_code VARCHAR(25) REFERENCES products(product_code),- **Customers**

    Quantity DECIMAL(10,2),

    UnitPrice DECIMAL(10,2)```sql

)INSERT INTO customers (CustomerID, Country, date)

```SELECT DISTINCT ON (CustomerID) CustomerID, Country, date

FROM e_comerce

---WHERE CustomerID IS NOT NULL

ON CONFLICT (CustomerID) DO NOTHING;

## 📁 Project Structure```



```- **Products**

e-commerce-analysis/

│```sql

├── sql/INSERT INTO products (product_code, Description, UnitPrice)

│   ├── 01_schema_setup.sql          # Database creation & normalizationSELECT DISTINCT ON (product_code) product_code, Description, UnitPrice

│   └── 02_business_analysis.sql     # 12 business intelligence queriesFROM e_comerce

│ON CONFLICT (product_code) DO NOTHING;

├── docs/```

│   ├── database_schema.png          # ERD diagram

│   └── TABLES.pgerd                 # pgAdmin ERD file- **Orders**

│

├── data/```sql

│   └── (place your CSV data here)INSERT INTO orders (InvoiceNo, date, CustomerID, product_code, Quantity, UnitPrice)

│SELECT invoice, date, CustomerID, product_code, Quantity, UnitPrice

├── README.md                        # This fileFROM e_comerce

├── START_HERE.md                    # Quick start guideON CONFLICT (InvoiceNo) DO NOTHING;

└── LICENSE                          # MIT License```

```

### Foreign Key Constraints

---

```sql

## 🔍 SQL QueriesALTER TABLE orders

    ADD CONSTRAINT fk_customer FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID),

### Schema Setup (`01_schema_setup.sql`)    ADD CONSTRAINT fk_product FOREIGN KEY (product_code) REFERENCES products(product_code);

1. Create raw data table

2. Clean & transform data (split datetime, rename columns)ALTER TABLE e_comerce

3. Create normalized tables (customers, products, orders)    ADD CONSTRAINT fk_invoices FOREIGN KEY (invoice) REFERENCES orders(InvoiceNo),

4. Insert data with deduplication    ADD CONSTRAINT fk_stockcode FOREIGN KEY (product_code) REFERENCES products(product_code),

5. Add foreign key constraints    ADD CONSTRAINT fk_customerid FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID);

```

### Business Analysis (`02_business_analysis.sql`)

---

| Query | Business Question | SQL Techniques |

|-------|------------------|----------------|## SQL Analytics

| 1. Business Overview | What are our key metrics? | Aggregations, COUNT DISTINCT |

| 2. Customer Activity | How many orders per customer? | GROUP BY, CASE WHEN |### High-Level Business Metrics

| 3. High-Value Customers | Who spends the most? | ORDER BY, LIMIT |

| 4. New vs Returning | Are we retaining customers? | CTEs, CASE expressions |- **Total number of customers**

| 5. Top Orders | Which orders made the most? | SUM, GROUP BY |    ```sql

| 6. Customer Lifetime Value | Who are our best customers? | Aggregations, calculations |    SELECT COUNT(DISTINCT customerid) FROM customers;

| 7. Monthly Revenue Trends | How is revenue changing? | LAG window function |    ```

| 8. Best Selling Products | What's #1 each month? | RANK, PARTITION BY |

| 9. Churned Customers | Who hasn't ordered in 90 days? | DATE arithmetic, intervals |- **Total number of orders**

| 10. Product Rankings | How do products rank monthly? | RANK over windows |    ```sql

| 11. Cumulative Revenue | What's our running total? | SUM window function |    SELECT COUNT(DISTINCT invoiceno) FROM orders;

| 12. Cohort Analysis | Which cohort is most valuable? | DATE_TRUNC, GROUP BY |    ```



---- **Total revenue**

    ```sql

## 💡 Business Insights    SELECT ROUND(SUM(quantity * unitprice)) AS total_revenue FROM orders;

    ```

### Key Metrics

- 📊 **4,372 unique customers**- **Average order value**

- 📦 **25,900 total orders**    ```sql

- 💰 **$590,571 total revenue**    SELECT ROUND(AVG(quantity * unitprice)) AS average_order_value FROM orders;

- 💵 **$23 average order value**    ```



### Customer Segments### Customer Behavior Analysis

- **VIP Customers**: 10+ orders (top revenue contributors)

- **Regular Customers**: 5-9 orders (steady business)- **Orders per customer**

- **Occasional Customers**: 1-4 orders (growth opportunity)    ```sql

    SELECT customerid, COUNT(invoiceno) AS orders

### Analysis Highlights    FROM orders

- Monthly revenue trends show seasonality patterns    WHERE customerid IS NOT NULL

- Top 10 customers contribute significant revenue share    GROUP BY customerid;

- Customer churn analysis identifies at-risk accounts    ```

- Cohort analysis reveals customer acquisition trends

- **Customers who bought more than 5 times**

---    ```sql

    SELECT customerid, COUNT(invoiceno) AS orders, ROUND(SUM(quantity)) AS amount

## 🛠️ Technologies Used    FROM orders

    WHERE customerid IS NOT NULL

- **Database**: PostgreSQL    GROUP BY customerid

- **SQL Techniques**:    HAVING SUM(quantity) > 5;

  - Common Table Expressions (CTEs)    ```

  - Window Functions (RANK, LAG, SUM OVER)

  - Date/Time Functions (DATE_TRUNC, intervals)- **New vs Returning customers per month**

  - Joins (INNER, LEFT)    ```sql

  - Aggregations (SUM, AVG, COUNT)    WITH first_purchase AS (

  - Subqueries        SELECT customerid, MIN(date) AS first_purchase

- **Tools**: pgAdmin 4, DBeaver, or any PostgreSQL client        FROM orders

        GROUP BY customerid

---    )

    SELECT 

## 🚀 Getting Started        DATE_TRUNC('month', o.date) AS month,

        COUNT(CASE WHEN o.date = f.first_purchase THEN 1 END) AS new_customers,

### Prerequisites        COUNT(CASE WHEN o.date > f.first_purchase THEN 1 END) AS returning_customers

- PostgreSQL 12+ installed    FROM orders o

- pgAdmin or any SQL client    JOIN first_purchase f ON o.customerid = f.customerid

- Basic SQL knowledge    GROUP BY DATE_TRUNC('month', o.date)

    ORDER BY month;

### Setup Instructions    ```



1. **Clone this repository**### Revenue & Product Analysis

   ```bash

   git clone https://github.com/Ahmed-Gohar1/e_commerce_analysis.git- **Top 10 products by revenue**

   cd e_commerce_analysis    ```sql

   ```    SELECT product_code, ROUND(SUM(quantity * unitprice)) AS revenue

    FROM orders

2. **Create database**    GROUP BY product_code

   ```sql    ORDER BY revenue DESC

   CREATE DATABASE ecommerce_db;    LIMIT 10;

   ```    ```



3. **Run schema setup**- **Top 10 customers by total spending**

   ```bash    ```sql

   psql -d ecommerce_db -f sql/01_schema_setup.sql    SELECT customerid, ROUND(SUM(quantity * unitprice)) AS revenue

   ```    FROM orders

    GROUP BY customerid

4. **Import your data** (if you have CSV files)    ORDER BY revenue DESC

   ```sql    LIMIT 10;

   COPY e_comerce FROM '/path/to/data.csv' CSV HEADER;    ```

   ```

- **Monthly revenue trends (top product per month)**

5. **Run business analysis queries**    ```sql

   ```bash    WITH ord AS (

   psql -d ecommerce_db -f sql/02_business_analysis.sql        SELECT 

   ```            DATE_TRUNC('month', o.date) AS month, 

            o.product_code,

For detailed instructions, see [START_HERE.md](START_HERE.md)            ROUND(SUM(o.quantity * o.unitprice)) AS revenue,

            RANK() OVER(PARTITION BY DATE_TRUNC('month', o.date) ORDER BY ROUND(SUM(o.quantity * o.unitprice)) DESC) AS rank

---        FROM orders o

        GROUP BY DATE_TRUNC('month', o.date), o.product_code

## 📚 Key Learnings    )

    SELECT 

This project demonstrates:        o.month,

        p.description, 

### Database Design        o.product_code,

- How to normalize a denormalized table into 3NF        o.revenue, 

- Proper use of primary keys and foreign keys        o.rank

- Data integrity through constraints    FROM ord o

    LEFT JOIN products p ON p.product_code = o.product_code

### SQL Skills    WHERE o.rank = 1

- Writing clean, readable queries with CTEs    ORDER BY o.month, o.rank;

- Using window functions for rankings and running totals    ```

- Performing cohort and trend analysis

- Date/time manipulation for business metrics### Churn & Cohort Analysis



### Business Analysis- **Customers who haven’t ordered in the last 90 days (churned)**

- Calculating key performance indicators (KPIs)    ```sql

- Customer segmentation strategies    WITH last_orders AS (

- Revenue trend analysis        SELECT customerid, MAX(date) AS last_purchase

- Churn prediction and retention metrics        FROM orders

        GROUP BY customerid

---    )

    SELECT c.customerid, l.last_purchase

## 👨‍💻 Author    FROM customers c

    LEFT JOIN last_orders l ON c.customerid = l.customerid

**Ahmed Gohar**    WHERE l.last_purchase IS NULL          

       OR l.last_purchase <= DATE '2011-12-09' - INTERVAL '90 days';

- GitHub: [@Ahmed-Gohar1](https://github.com/Ahmed-Gohar1)    ```

- LinkedIn: [Connect with me](https://www.linkedin.com/in/ahmed-gohar1)

- **Cohort analysis (group by signup month)**

---    ```sql

    SELECT 

## 📄 License        customerid,

        DATE_TRUNC('month', date) AS cohort_month

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.    FROM customers;

    ```

---

### Advanced SQL Techniques

## 🌟 Acknowledgments

- **Rank products by revenue each month**

- Dataset inspired by real-world e-commerce transaction data    ```sql

- ERD created with pgAdmin 4    WITH monthly_revenue AS (

- Project structure follows industry best practices        SELECT 

            DATE_TRUNC('month', o.date) AS month,

---            p.product_code,

            p.description,

**⭐ If you find this project helpful, please give it a star!**            SUM(o.quantity * o.unitprice) AS revenue

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
