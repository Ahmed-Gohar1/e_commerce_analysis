-- e_comerce table creation

CREATE TABLE e_comerce (
	InvoiceNo	VARCHAR(25),
	StockCode	VARCHAR(25), --fk @@
	Description	VARCHAR(65), 
	Quantity	DECIMAL(10,2),
	InvoiceDate	TIMESTAMP,
	UnitPrice	DECIMAL(10,2),
	CustomerID	VARCHAR(25), --fk @@
	Country		VARCHAR(25)
);

ALTER TABLE e_comerce
ADD COLUMN id SERIAL PRIMARY KEY;

-- cleaning

-- column split date and time

ALTER TABLE e_comerce
ADD COLUMN date_only DATE,
ADD COLUMN time_only TIME;

UPDATE e_comerce
SET date_only = CAST(InvoiceDate AS DATE),
    time_only = CAST(InvoiceDate AS TIME);
SELECT * FROM e_comerce;

-- delete datetime (timestamp)

ALTER TABLE e_comerce
DROP COLUMN InvoiceDate;
SELECT * FROM e_comerce;

-- Identify main entities (Customers, Products, Orders, etc.).

ALTER TABLE e_comerce RENAME COLUMN InvoiceNo TO invoice;
ALTER TABLE e_comerce RENAME COLUMN StockCode TO product_code;
ALTER TABLE e_comerce RENAME COLUMN date_only TO date;
ALTER TABLE e_comerce RENAME COLUMN time_only TO time;

-- Create new normalized tables:
-- customers table

CREATE TABLE customers(
	CustomerID	VARCHAR(25) PRIMARY KEY ,
	Country		VARCHAR(25),
	date 		date
);

-- products table

CREATE TABLE products(
	product_code VARCHAR(25) PRIMARY KEY ,
	Description  VARCHAR(65),
	UnitPrice	DECIMAL(10,2)
);
-- orders table

CREATE TABLE orders(
	InvoiceNo	VARCHAR(25) PRIMARY KEY,
	date 		date,
	CustomerID	VARCHAR(25), -- fk @@
	product_code VARCHAR(25), -- fk @@
	Quantity	DECIMAL(10,2),
	UnitPrice	DECIMAL(10,2)
);

-- data insertion

-- customers

INSERT INTO customers (CustomerID, Country, date)
SELECT DISTINCT ON (CustomerID) CustomerID, Country, date
FROM e_comerce
WHERE CustomerID IS NOT NULL
ON CONFLICT (CustomerID) DO NOTHING;

select * from customers;

-- products

INSERT INTO products (product_code, Description, UnitPrice)
SELECT DISTINCT ON (product_code) product_code, Description, UnitPrice
FROM e_comerce
ON CONFLICT (product_code) DO NOTHING;

select * from products;

-- orders

INSERT INTO orders (InvoiceNo, date, CustomerID, product_code, Quantity, UnitPrice)
SELECT Invoice, date, CustomerID, product_code, Quantity, UnitPrice
FROM e_comerce
ON CONFLICT (InvoiceNo) DO NOTHING;

select * from orders;

-- foregin keys

-- orders

ALTER TABLE  orders
ADD CONSTRAINT fk_customer
FOREIGN KEY (CustomerID)
REFERENCES customers(CustomerID);

ALTER TABLE orders 
ADD CONSTRAINT fk_product
FOREIGN KEY (product_code)
REFERENCES products(product_code);

-- e_comerce

ALTER TABLE  e_comerce
ADD CONSTRAINT fk_invoices
FOREIGN KEY (invoice)
REFERENCES orders(InvoiceNo);

ALTER TABLE  e_comerce
ADD CONSTRAINT fk_stockcode
FOREIGN KEY (product_code)
REFERENCES products(product_code);

ALTER TABLE  e_comerce
ADD CONSTRAINT fk_customerid
FOREIGN KEY (CustomerID)
REFERENCES customers(CustomerID);

