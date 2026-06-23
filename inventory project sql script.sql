USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'InventoryDB')
BEGIN
    ALTER DATABASE InventoryDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE InventoryDB;
END
GO

CREATE DATABASE InventoryDB;
GO

USE InventoryDB;
GO


---------------------------------------------------


CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100)
);

CREATE TABLE brands (
    brand_id INT PRIMARY KEY,
    brand_name VARCHAR(100)
);

CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    street VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    zip_code VARCHAR(20)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    full_name VARCHAR(200),
    phone VARCHAR(20),
    email VARCHAR(100),
    street VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    zip_code VARCHAR(20)
);

CREATE TABLE staffs (
    staff_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    full_staffname VARCHAR(200),
    email VARCHAR(100),
    phone VARCHAR(20),
    active INT,
    store_id INT,
    manager_id INT,

    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    brand_id INT,
    category_id INT,
    model_year INT,
    list_price DECIMAL(10,2),

    FOREIGN KEY (brand_id) REFERENCES brands(brand_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_status INT,
    order_date DATE,
    required_date DATE,
    shipped_date DATE,
    store_id INT,
    staff_id INT,

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (staff_id) REFERENCES staffs(staff_id)
);

CREATE TABLE order_items (
    order_id INT,
    item_id INT,
    product_id INT,
    quantity INT,
    list_price DECIMAL(10,2),
    discount DECIMAL(10,2),
    revenue DECIMAL(12,2),

    PRIMARY KEY (order_id, item_id),

    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE stocks (
    store_id INT,
    product_id INT,
    quantity INT,

    PRIMARY KEY (store_id, product_id),

    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


---------------------------------------------------
-- TEMP TABLES


CREATE TABLE orders_temp (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_date VARCHAR(50),
    required_date VARCHAR(50),
    shipped_date VARCHAR(50),
    store_id VARCHAR(50),
    staff_id VARCHAR(50)
);

CREATE TABLE order_items_temp (
    order_id VARCHAR(50),
    item_id VARCHAR(50),
    product_id VARCHAR(50),
    quantity VARCHAR(50),
    list_price VARCHAR(50),
    discount VARCHAR(50),
    revenue VARCHAR(50)
);


---------------------------------------------------
-- BULK INSERT SAFE TABLES


BULK INSERT brands
FROM 'C:\Users\Shlok\OneDrive\Desktop\SQLData\brands.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);

BULK INSERT categories
FROM 'C:\Users\Shlok\OneDrive\Desktop\SQLData\categories.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);

BULK INSERT stores
FROM 'C:\Users\Shlok\OneDrive\Desktop\SQLData\stores.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);

BULK INSERT customers
FROM 'C:\Users\Shlok\OneDrive\Desktop\SQLData\customers.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);

BULK INSERT staffs
FROM 'C:\Users\Shlok\OneDrive\Desktop\SQLData\staffs.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);

BULK INSERT products
FROM 'C:\Users\Shlok\OneDrive\Desktop\SQLData\products.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);

BULK INSERT stocks
FROM 'C:\Users\Shlok\OneDrive\Desktop\SQLData\stocks.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);


---------------------------------------------------
-- BULK INSERT TEMP TABLES
---------------------------------------------------

BULK INSERT orders_temp
FROM 'C:\Users\Shlok\OneDrive\Desktop\SQLData\orders.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);

BULK INSERT order_items_temp
FROM 'C:\Users\Shlok\OneDrive\Desktop\SQLData\order_items.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);


---------------------------------------------------
-- INSERT CLEAN DATA

INSERT INTO orders
SELECT
    CAST(order_id AS INT),
    CAST(customer_id AS INT),
    CAST(order_status AS INT),
    TRY_CAST(order_date AS DATE),
    TRY_CAST(required_date AS DATE),
    TRY_CAST(shipped_date AS DATE),
    CAST(store_id AS INT),
    CAST(staff_id AS INT)
FROM orders_temp;

INSERT INTO order_items
SELECT
    CAST(order_id AS INT),
    CAST(item_id AS INT),
    CAST(product_id AS INT),
    CAST(quantity AS INT),
    CAST(list_price AS DECIMAL(10,2)),
    CAST(discount AS DECIMAL(10,2)),
    CAST(revenue AS DECIMAL(12,2))
FROM order_items_temp;


---------------------------------------------------
-- VALIDATE

SELECT COUNT(*) AS brands_count FROM brands;
SELECT COUNT(*) AS categories_count FROM categories;
SELECT COUNT(*) AS stores_count FROM stores;
SELECT COUNT(*) AS customers_count FROM customers;
SELECT COUNT(*) AS staffs_count FROM staffs;
SELECT COUNT(*) AS products_count FROM products;
SELECT COUNT(*) AS orders_count FROM orders;
SELECT COUNT(*) AS order_items_count FROM order_items;
SELECT COUNT(*) AS stocks_count FROM stocks;


TRUNCATE TABLE orders_temp;
TRUNCATE TABLE order_items_temp;


BULK INSERT orders_temp
FROM 'C:\Users\Shlok\OneDrive\Desktop\SQLData\orders.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0d0a'
);

BULK INSERT order_items_temp
FROM 'C:\Users\Shlok\OneDrive\Desktop\SQLData\order items .csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0d0a'
);


SELECT COUNT(*) FROM orders_temp;
SELECT * FROM order_items_temp;


TRUNCATE TABLE orders
TRUNCATE TABLE order_items_temp;

ALTER TABLE order_items_temp
ALTER COLUMN revenue DECIMAL(18,2);
-----------------------------------------------------------------------------------------------------------------------------------------------

-- Top Brands 

SELECT 
    b.brand_name,
    ROUND(SUM(CAST(oi.quantity AS INT) * CAST(oi.list_price AS DECIMAL(18,2))), 2) AS revenue
FROM order_items_temp oi
JOIN products p on oi.product_id = p.product_id
JOIN brands b on p.brand_id = b.brand_id
GROUP BY b.brand_name
ORDER BY revenue DESC;


--delays 

SELECT 
    order_id,
    CONVERT(DATE, order_date, 103) AS order_date,     
    CONVERT(DATE, required_date, 103) AS required_date,
    CONVERT(DATE, shipped_date, 103) AS shipped_date,
    DATEDIFF(DAY, CONVERT(DATE, required_date, 103), CONVERT(DATE, shipped_date, 103)) AS delay_days
FROM orders_temp
WHERE CONVERT(DATE, shipped_date, 103) > CONVERT(DATE, required_date, 103);


                                                  -- Store-wise and Region-wise sales analysis

--(store wise)
SELECT 
    s.store_id,
    s.store_name,
    s.city,
    s.state,
    SUM(oi.revenue) AS total_revenue,                        
    SUM(TRY_CAST(oi.quantity AS INT)) AS total_quantity_sold 
FROM orders_temp o
JOIN stores s ON o.store_id = s.store_id
JOIN order_items_temp oi ON o.order_id = oi.order_id
GROUP BY 
    s.store_id, 
    s.store_name, 
    s.city, 
    s.state
ORDER BY total_revenue DESC;


-- (region wise) 
SELECT 
    s.state,
    SUM(oi.revenue) AS total_revenue,                        
    SUM(TRY_CAST(oi.quantity AS INT)) AS total_quantity_sold 
FROM orders_temp o
JOIN stores s ON o.store_id = s.store_id
JOIN order_items_temp oi ON o.order_id = oi.order_id
GROUP BY s.state
ORDER BY total_revenue DESC;



-----------------------------------------------------------------------------------------------------------------------------------------------


                                                     -- Product-wise sales and inventory trends

SELECT 
    p.product_id,
    p.product_name,
    b.brand_name,
    c.category_name,
    SUM(TRY_CAST(oi.quantity AS INT)) AS total_quantity_sold,
    ROUND(SUM(oi.revenue),2) AS total_revenue
FROM order_items_temp oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN brands b
    ON p.brand_id = b.brand_id
JOIN categories c
    ON p.category_id = c.category_id
GROUP BY 
    p.product_id,
    p.product_name,
    b.brand_name,
    c.category_name
ORDER BY total_revenue DESC;


--(remaining inventory )

SELECT 
    p.product_id,
    p.product_name,
    SUM(s.quantity) AS inventory_stock
FROM stocks s
JOIN products p ON s.product_id = p.product_id
GROUP BY 
    p.product_id,
    p.product_name
ORDER BY inventory_stock ASC;


-----------------------------------------------------------------------------------------------------------------------------------------------

-- Staff performance reports

select * from staffs

--(staff performance)
SELECT 
    st.staff_id,
    st.full_staffname,
    COUNT(DISTINCT o.order_id) AS total_orders_handled,
    SUM(TRY_CAST(oi.quantity AS INT)) AS total_quantity_sold,
    ROUND(SUM(oi.revenue),2) AS total_revenue_generated
FROM staffs st
JOIN orders_temp o ON st.staff_id = o.staff_id
JOIN order_items_temp oi ON o.order_id = oi.order_id
GROUP BY st.staff_id, st.full_staffname
ORDER BY total_revenue_generated desc;

-----------------------------------------------------------------------------------------------------------------------------------------------

                                -- Customer orders and order frequency

SELECT 
    c.customer_id,
    c.full_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.revenue),2) AS total_spent,
    MAX(o.order_date) AS last_order_date
FROM customers c
JOIN orders_temp o ON c.customer_id = o.customer_id
JOIN order_items_temp oi ON o.order_id = oi.order_id
GROUP BY c.customer_id,c.full_name
ORDER BY total_orders DESC;



SELECT 
    customer_type,
    COUNT(*) AS total_customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM (
    SELECT 
        customer_id,
        CASE 
            WHEN COUNT(order_id) = 1 THEN 'one time customer'
            ELSE 'repeat customer'
        END AS customer_type
    FROM orders_temp
    GROUP BY customer_id
)t
GROUP BY customer_type;


-----------------------------------------------------------------------------------------------------------------------------------------------

                                                      -- Revenue and discount analysis

SELECT 
    ROUND(SUM(TRY_CAST(quantity AS INT) * TRY_CAST(list_price AS DECIMAL(18,2))), 2) AS gros_Sale,
    ROUND(SUM(TRY_CAST(discount AS DECIMAL(18,2)) * TRY_CAST(quantity AS INT)), 2) AS ttl_discount,
    ROUND(SUM(revenue), 2) AS net_revenue
FROM order_items_temp;


SELECT 
    p.product_name,
    ROUND(AVG(TRY_CAST(discount AS DECIMAL(18,2))),2) as avg_discount,
    ROUND(SUM(oi.revenue), 2) AS total_revenue
FROM order_items_temp oi
JOIN products p ON CAST(oi.product_id AS INT) = p.product_id 
GROUP BY p.product_name
ORDER BY avg_discount DESC;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--(monthly trend) 

SELECT 
    YEAR(CONVERT(DATE, o.order_date, 103)) AS order_year,
    MONTH(CONVERT(DATE, o.order_date, 103)) AS order_month,
    ROUND(SUM(oi.revenue), 2) AS monthly_revenue
FROM orders_temp o
JOIN order_items_temp oi on o.order_id = oi.order_id
GROUP BY 
    YEAR(CONVERT(DATE, o.order_date, 103)),
    MONTH(CONVERT(DATE, o.order_date, 103))
ORDER BY 
    order_year,
    order_month;


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Segmentantion 

WITH customer_sales AS
(
    SELECT
        c.customer_id,
        c.full_name,
        SUM(oi.revenue) AS total_spent
    FROM customers c
    JOIN orders_temp o on c.customer_id = o.customer_id
    JOIN order_items_temp oi on o.order_id = oi.order_id
    GROUP BY 
        c.customer_id,
        c.full_name
)
SELECT *,
    CASE
        WHEN total_spent >= 7000 THEN 'High Value'
        WHEN total_spent >= 3500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM customer_sales
ORDER BY total_spent DESC;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                                 -- Create SQL Views for reusable insights.

CREATE VIEW inventory_status AS
SELECT 
    p.product_id,
    p.product_name,
    b.brand_name,
    c.category_name,
    SUM(s.quantity) AS stock_available
FROM products p
JOIN brands b ON p.brand_id = b.brand_id
JOIN categories c ON p.category_id = c.category_id
JOIN stocks s ON p.product_id = s.product_id
GROUP BY 
    p.product_id,
    p.product_name,
    b.brand_name,
    c.category_name;




CREATE VIEW cust_lifetime_vslue AS
SELECT 
    c.customer_id,
    c.full_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.revenue),2) AS lifetime_value
FROM customers c
JOIN orders_temp o
    ON c.customer_id = o.customer_id
JOIN order_items_temp oi
    ON o.order_id = oi.order_id
GROUP BY 
    c.customer_id,
    c.full_name;



CREATE VIEW sales_summary AS
SELECT 
    o.order_id,
    o.order_date,
    c.full_name AS customer_name,
    s.store_name,
    st.full_staffname AS staff_name,
    ROUND(SUM(oi.revenue),2) AS order_revenue
FROM orders_temp o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN stores s
    ON o.store_id = s.store_id
JOIN staffs st
    ON o.staff_id = st.staff_id
JOIN order_items_temp oi
    ON o.order_id = oi.order_id
GROUP BY 
    o.order_id,
    o.order_date,
    c.full_name,
    s.store_name,
    st.full_staffname;



SELECT * FROM sales_summary;
SELECT * FROM inventory_status;
SELECT * FROM cust_lifetime_vslue;



SELECT @@SERVER NAME;