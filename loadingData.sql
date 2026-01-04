CREATE DATABASE customer_order 
GO 

USE customer_order;


CREATE TABLE Orders (
    order_id INT,
    customer_name VARCHAR(150),
    email VARCHAR(200),
    order_date Date,
    product_name VARCHAR(200),
    quantity VARCHAR(10),
    price VARCHAR(50),
    country VARCHAR(100),
    order_status VARCHAR(50),
    notes VARCHAR(500)
);

BULK INSERT Orders
FROM "C:\Users\Muhammad_Danishh\Downloads\customer_orders - Sheet1.csv"
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);