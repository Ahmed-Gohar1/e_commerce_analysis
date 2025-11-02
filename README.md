# 🛒 E-Commerce SQL Analytics Project

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-12+-blue.svg)](https://www.postgresql.org/)
[![SQL](https://img.shields.io/badge/SQL-CTEs%20%26%20Window%20Functions-green.svg)](https://www.postgresql.org/docs/)
[![License](https://img.shields.io/badge/License-MIT-orange.svg)](LICENSE)

> **Complete SQL-based e-commerce analytics project demonstrating database design, data normalization, and business intelligence. Features 20 beginner-friendly queries with CTEs, covering customer segmentation, revenue analysis, and retention metrics.**

---

## 📊 Project Overview

This project showcases a comprehensive e-commerce analytics pipeline using SQL, demonstrating professional database design and business intelligence skills. Starting from raw transaction data, the project transforms, normalizes, and analyzes sales data to extract actionable business insights.

### 🎯 Key Objectives
- Transform and normalize raw e-commerce transaction data
- Design a clean, 3NF (Third Normal Form) relational database schema
- Answer 20 real-world business questions using SQL
- Demonstrate modern SQL techniques (CTEs, window functions, joins)
- Generate insights for customer retention, revenue trends, and product performance

### 📈 Database Summary

| Attribute | Details |
|-----------|---------|
| **Customers** | 4,372 unique customers |
| **Orders** | 25,900 total transactions |
| **Revenue** | $590,571 total sales |
| **Products** | Multiple SKUs tracked |
| **Schema** | 3 normalized tables (customers, products, orders) |

---

## 🗂️ Database Schema

![Database ERD](docs/database_schema.png)

### Original Raw Table

**`e_comerce`** - Raw transaction data requiring normalization

| Column | Type | Description |
|--------|------|-------------|
| `InvoiceNo` | VARCHAR(25) | Unique invoice identifier |
| `StockCode` | VARCHAR(25) | Product code/SKU |
| `Description` | VARCHAR(65) | Product description |
| `Quantity` | DECIMAL(10,2) | Quantity purchased |
| `InvoiceDate` | TIMESTAMP | Date and time of purchase |
| `UnitPrice` | DECIMAL(10,2) | Price per unit |
| `CustomerID` | VARCHAR(25) | Customer identifier |
| `Country` | VARCHAR(25) | Customer country |

### Normalized Schema (3NF)

**1. `customers`** - Customer master data

| Column | Type | Constraint | Description |
|--------|------|-----------|-------------|
| `CustomerID` | VARCHAR(25) | PRIMARY KEY | Unique customer identifier |
| `Country` | VARCHAR(25) | | Customer location |
| `date` | DATE | | First purchase date |

**2. `products`** - Product catalog

| Column | Type | Constraint | Description |
|--------|------|-----------|-------------|
| `product_code` | VARCHAR(25) | PRIMARY KEY | Unique product SKU |
| `Description` | VARCHAR(65) | | Product name/description |
| `UnitPrice` | DECIMAL(10,2) | | Standard unit price |

**3. `orders`** - Transaction records

| Column | Type | Constraint | Description |
|--------|------|-----------|-------------|
| `InvoiceNo` | VARCHAR(25) | PRIMARY KEY | Unique order identifier |
| `date` | DATE | | Order date |
| `CustomerID` | VARCHAR(25) | FOREIGN KEY → customers | Customer reference |
| `product_code` | VARCHAR(25) | FOREIGN KEY → products | Product reference |
| `Quantity` | DECIMAL(10,2) | | Quantity ordered |
| `UnitPrice` | DECIMAL(10,2) | | Price at time of order |

---

## 🏗️ Project Structure

```
d:\projects\nn\
├── 📄 sql/                                  # SQL scripts
│   ├── 01_schema_setup.sql                 # Database creation, normalization, and data loading
│   └── 02_business_analysis.sql            # 20 business intelligence queries with CTEs
│
├── 📂 docs/                                 # Documentation and diagrams
│   ├── database_schema.png                 # Entity-Relationship Diagram (ERD)
│   └── TABLES.pgerd                        # pgAdmin ERD source file
│
├── 📂 data/                                 # Data files (place your CSV here)
│   └── (your e-commerce CSV data)
│
├── 📚 Documentation
│   ├── README.md                           # This file - main documentation
│   └── START_HERE.md                       # Quick start guide
│
└── 📄 LICENSE                               # MIT License

```

---

## 🔍 SQL Query Catalog

### 📋 Schema Setup (`01_schema_setup.sql`)

This script handles the complete database setup and normalization process:

1. **Create Raw Table** - Initial `e_comerce` table with all transaction fields
2. **Data Cleaning** - Split datetime columns, rename fields for clarity
3. **Normalize Schema** - Create `customers`, `products`, and `orders` tables following 3NF
4. **Data Migration** - Insert data with `ON CONFLICT` handling for deduplication
5. **Add Constraints** - Establish foreign key relationships for referential integrity
6. **Quality Checks** - 5 validation queries to ensure data integrity

### 📊 Business Analysis (`02_business_analysis.sql`) - 20 Queries

All queries use **CTEs (Common Table Expressions)** for clean, readable SQL.

| # | Query Name | Business Question | SQL Techniques |
|---|------------|-------------------|----------------|
| **📌 Basic Metrics (1-6)** |||
| 1 | Business Overview | What are our key performance metrics? | `COUNT DISTINCT`, `SUM`, `AVG`, aggregations |
| 2 | Customer Activity | How many orders per customer? | `GROUP BY`, `CASE WHEN`, conditional logic |
| 3 | High-Value Customers | Who are our top spending customers? | `ORDER BY`, `LIMIT`, ranking |
| 4 | New vs Returning | Are we retaining customers? | `MIN`, `CASE`, date comparison |
| 5 | Top Orders | Which orders generated the most revenue? | `SUM`, `GROUP BY`, calculations |
| 6 | Customer Lifetime Value | Who are our most valuable customers overall? | Aggregations, customer-level metrics |
| **📈 Trends & Patterns (7-12)** |||
| 7 | Monthly Revenue Trends | How is revenue changing month-over-month? | `LAG` window function, trend analysis |
| 8 | Best Selling Products | What's the #1 product each month? | `RANK`, `PARTITION BY`, window functions |
| 9 | Churned Customers | Who hasn't ordered in 90+ days? | `DATE` arithmetic, `INTERVAL`, retention |
| 10 | Product Rankings | How do products rank by revenue monthly? | `RANK OVER`, partitioning |
| 11 | Cumulative Revenue | What's our running revenue total? | `SUM OVER (ORDER BY)`, cumulative sums |
| 12 | Cohort Analysis | Which signup cohort is most valuable? | `DATE_TRUNC`, cohort grouping |
| **🎯 Advanced Analytics (13-20)** |||
| 13 | Purchase Frequency | How often do customers purchase? | Frequency distribution, bucketing |
| 14 | Product Performance | High volume vs high value products? | Categorization, segmentation |
| 15 | Customer Retention | Do customers make repeat purchases? | Repeat purchase tracking |
| 16 | Day of Week Patterns | What day of the week sells best? | `EXTRACT(DOW)`, temporal patterns |
| 17 | Products Bought Together | What products sell together? | Self-join, market basket analysis |
| 18 | Customer Segments | Who are our VIP, Regular, Occasional customers? | RFM segmentation (simplified) |
| 19 | Seasonal Analysis | Which quarter/season performs best? | `EXTRACT(QUARTER)`, seasonal trends |
| 20 | Order Size Distribution | What's the distribution of order sizes? | Bucketing, histogram analysis |

---

## 💡 Key Business Insights

### 📊 Overall Metrics
- **4,372** unique customers across multiple countries
- **25,900** total orders processed
- **$590,571** in total revenue generated
- **$23** average order value

### 👥 Customer Segmentation

| Segment | Criteria | Business Impact |
|---------|----------|-----------------|
| **VIP Customers** | 10+ orders, $5K+ spent | Top revenue contributors - focus on retention |
| **Good Customers** | 5-9 orders, $2K+ spent | Solid customer base - upsell opportunities |
| **Regular Customers** | 3-4 orders | Growth potential - engagement campaigns |
| **New/Occasional** | 1-2 orders | Retention focus - win-back strategies |

### 🎯 Key Findings
- 📈 **Monthly revenue shows clear seasonal patterns** - optimize inventory accordingly
- 💰 **Top 10 customers drive significant revenue share** - implement VIP programs
- ⚠️ **Churn analysis identifies at-risk accounts** - proactive retention campaigns
- 🔗 **Product affinity reveals cross-sell opportunities** - bundle promotions
- 📅 **Day-of-week analysis optimizes marketing timing** - schedule campaigns strategically
- 🎁 **Cohort analysis shows customer acquisition trends** - refine targeting

---

## 🛠️ Technologies Used

- **Database**: PostgreSQL 12+ (compatible with PostgreSQL 10+)
- **SQL Features**:
  - ✅ Common Table Expressions (CTEs)
  - ✅ Window Functions (`RANK`, `LAG`, `SUM OVER`)
  - ✅ Date/Time Functions (`EXTRACT`, `DATE_TRUNC`, `INTERVAL`)
  - ✅ Joins (INNER, LEFT, self-joins)
  - ✅ Aggregations (`SUM`, `AVG`, `COUNT`, `MIN`, `MAX`, `ROUND`)
  - ✅ Conditional Logic (`CASE WHEN`)
  - ✅ Subqueries and derived tables
- **Tools**: pgAdmin 4, DBeaver, psql CLI, or any PostgreSQL client

---

## 🚀 Getting Started

### Prerequisites

- **PostgreSQL 12+** installed ([Download here](https://www.postgresql.org/download/))
- **SQL client** (pgAdmin 4, DBeaver, or psql command-line)
- **15 minutes** of your time

### Quick Setup

#### 1. Clone Repository
```powershell
git clone https://github.com/Ahmed-Gohar1/e_commerce_analysis.git
cd e_commerce_analysis
```

#### 2. Create Database
```sql
CREATE DATABASE ecommerce_db;
```

#### 3. Run Schema Setup
```powershell
# Using psql
psql -d ecommerce_db -f sql/01_schema_setup.sql

# Or open in pgAdmin and execute
```

#### 4. Import Your Data (Optional)
If you have CSV data:
```sql
COPY e_comerce FROM 'C:\path\to\data.csv' CSV HEADER;
```

#### 5. Run Business Analysis Queries
```powershell
# Using psql
psql -d ecommerce_db -f sql/02_business_analysis.sql

# Or run individual queries in your SQL client
```

### Alternative: Use pgAdmin GUI
1. Open pgAdmin 4
2. Create new database `ecommerce_db`
3. Open Query Tool
4. Load and execute `01_schema_setup.sql`
5. Load and execute `02_business_analysis.sql`

📖 **For detailed step-by-step instructions, see [START_HERE.md](START_HERE.md)**

---

## 📚 SQL Skills Demonstrated

### ✅ Core SQL
- `SELECT`, `WHERE`, `GROUP BY`, `ORDER BY`, `LIMIT`
- Joins (INNER, LEFT, self-joins for market basket analysis)
- Aggregations (`SUM`, `AVG`, `COUNT`, `MIN`, `MAX`)
- Subqueries and derived tables
- Filtering with `HAVING` clause

### ✅ Intermediate SQL
- **CTEs (Common Table Expressions)** - All 20 queries demonstrate proper CTE usage
- **Window Functions** - `RANK()`, `LAG()`, `SUM() OVER()`
- **Date Manipulation** - `EXTRACT()`, `DATE_TRUNC()`, `INTERVAL` arithmetic
- **Conditional Logic** - `CASE WHEN` for categorization and segmentation
- **String Functions** - Data cleaning and transformation

### ✅ Advanced SQL
- **Multiple Sequential CTEs** - Breaking complex queries into logical steps
- **Partitioned Window Functions** - Rankings within groups (`PARTITION BY`)
- **Self-Joins** - Product affinity and market basket analysis
- **Complex Date Arithmetic** - Cohort analysis, retention tracking
- **Running Totals** - Cumulative revenue with `SUM() OVER (ORDER BY)`

### ✅ Database Design
- **Normalization** - Converting 1NF to 3NF (Third Normal Form)
- **Primary Keys** - Ensuring unique identifiers
- **Foreign Keys** - Maintaining referential integrity
- **Data Integrity Constraints** - Preventing orphaned records
- **Schema Design Best Practices** - Separation of concerns

### ✅ Business Analysis
- **Customer Segmentation** - RFM model (Recency, Frequency, Monetary)
- **Cohort Analysis** - Tracking customer groups over time
- **Retention Metrics** - Churn identification and repeat purchase rates
- **Revenue Trend Analysis** - Month-over-month growth patterns
- **Product Affinity Analysis** - Cross-sell opportunities

---

## 🌟 Why This Project Stands Out

### 💼 For Job Interviews
- ✅ **CTE Mastery**: All 20 queries use CTEs - demonstrates modern SQL practices
- ✅ **Business Focus**: Shows you understand the "why" behind the SQL, not just syntax
- ✅ **Explainable**: Simple enough to walk through step-by-step in interviews
- ✅ **Real-World Scenarios**: Solves actual e-commerce business problems

### 📚 For Learning
- ✅ **Beginner-Friendly**: Queries build progressively from simple to advanced
- ✅ **Well-Documented**: Every query includes comments explaining the business problem
- ✅ **Practical**: Based on real e-commerce transaction patterns
- ✅ **Comprehensive**: Covers all major SQL concepts

### 🎨 For Portfolio
- ✅ **Professional Structure**: Clean folder organization and documentation
- ✅ **Complete Pipeline**: Database design → normalization → analysis
- ✅ **Visual Documentation**: ERD diagram included
- ✅ **GitHub Ready**: Professional README, clear structure, MIT license

---

## 👨‍💻 Author

**Ahmed Gohar**

- 🐙 GitHub: [@Ahmed-Gohar1](https://github.com/Ahmed-Gohar1)
- 💼 LinkedIn: [Connect with me](https://www.linkedin.com/in/ahmed-gohar1)

### 🚀 Other Projects
- 📊 [Telco Customer Churn Prediction](https://github.com/Ahmed-Gohar1/telco-churn-prediction) - Machine Learning with Scikit-learn
- 🚗 [BMW Sales Data Analysis](https://github.com/Ahmed-Gohar1/bmw-sales-analysis) - Statistical Analysis with Python

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 Questions or Feedback?

- 🐛 **Found an issue?** Open an issue on GitHub
- 💡 **Have suggestions?** Submit a pull request
- 📚 **Need help?** Check [START_HERE.md](START_HERE.md) for detailed instructions
- 💬 **Questions?** Review the SQL comments in each file

---

## 🌟 Acknowledgments

- Dataset inspired by real-world e-commerce transaction patterns
- ERD created with pgAdmin 4
- Project structure follows industry best practices
- Designed for PostgreSQL 12+ syntax

---

**⭐ If you find this project helpful, please give it a star!**

**🔗 Live at: [github.com/Ahmed-Gohar1/e_commerce_analysis](https://github.com/Ahmed-Gohar1/e_commerce_analysis)**

---

*Last Updated: November 2, 2025*
