# 🚀 START HERE - Quick Setup Guide

Welcome to the E-Commerce Sales Analysis project! This guide will get you up and running in minutes.

---

## 📋 What You'll Need

- ✅ PostgreSQL installed (version 12 or higher)
- ✅ A SQL client (pgAdmin, DBeaver, or psql command line)
- ✅ 10 minutes of your time

---

## 🎯 Quick Start (3 Steps)

### Step 1: Create the Database

Open your PostgreSQL client and run:

```sql
CREATE DATABASE ecommerce_db;
```

### Step 2: Set Up the Schema

Run the first SQL file to create and normalize your tables:

```bash
# Using psql command line:
psql -d ecommerce_db -f sql/01_schema_setup.sql

# OR copy and paste the contents of sql/01_schema_setup.sql into your SQL client
```

This will:
- ✅ Create the raw `e_comerce` table
- ✅ Clean and transform the data
- ✅ Create normalized tables: `customers`, `products`, `orders`
- ✅ Set up foreign key relationships

### Step 3: Run the Analysis

Execute the business intelligence queries:

```bash
# Using psql command line:
psql -d ecommerce_db -f sql/02_business_analysis.sql

# OR copy individual queries from sql/02_business_analysis.sql
```

---

## 📊 What You'll Get

After running the queries, you'll have insights on:

1. **Business Overview**: Total customers, orders, revenue
2. **Customer Segmentation**: VIP vs Regular vs Occasional
3. **Top Performers**: Best customers and products
4. **Trends**: Monthly revenue growth
5. **Churn Analysis**: Customers at risk
6. **Cohort Analysis**: Customer acquisition patterns

---

## 🗂️ Project Structure

```
e-commerce-analysis/
│
├── sql/
│   ├── 01_schema_setup.sql         👈 Run this FIRST
│   └── 02_business_analysis.sql    👈 Run this SECOND
│
├── docs/
│   ├── database_schema.png         📸 Visual ERD
│   └── TABLES.pgerd                🔧 pgAdmin ERD file
│
└── data/
    └── (your CSV files go here)    📁 Data storage
```

---

## 💡 Tips for Success

### For Beginners
- Run each query from `02_business_analysis.sql` **one at a time**
- Read the comments to understand what each query does
- Check the results to see the data patterns

### For Interviews
- Practice explaining the business question before showing the SQL
- Walk through the CTEs step by step
- Mention the SQL techniques used (window functions, joins, etc.)

### For Portfolio
- Take screenshots of interesting results
- Add your own queries based on business questions
- Customize the README with your insights

---

## 🎓 Learning Path

### Beginner Level
1. Run Query 1-3 (Basic aggregations)
2. Understand GROUP BY and COUNT
3. Learn about CTEs

### Intermediate Level
4. Run Query 4-8 (Window functions)
5. Understand RANK and PARTITION BY
6. Master date functions

### Advanced Level
7. Run Query 9-12 (Complex analysis)
8. Build custom cohort analysis
9. Create your own business questions

---

## 🔧 Troubleshooting

### "Database does not exist"
```sql
-- Make sure you created the database first:
CREATE DATABASE ecommerce_db;
```

### "Table already exists"
```sql
-- Drop existing tables if you want to start fresh:
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS e_comerce CASCADE;
```

### "Permission denied"
```sql
-- Make sure you have proper privileges:
GRANT ALL PRIVILEGES ON DATABASE ecommerce_db TO your_username;
```

---

## 📖 Next Steps

1. ✅ Complete the setup above
2. 📊 Run all 12 business analysis queries
3. 📝 Read the main [README.md](README.md) for detailed documentation
4. 🎯 Customize queries for your own use cases
5. ⭐ Star this repo if you found it helpful!

---

## 🆘 Need Help?

- Check the [README.md](README.md) for full documentation
- Review SQL comments in each file
- Open an issue on GitHub if you encounter problems

---

**Ready to dive in? Start with Step 1 above! 🚀**
