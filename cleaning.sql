SELECT TOP 3 * 
FROM Orders



  -- STANDARDIZE THE ORDER STATUS COLUMN

SELECT order_status,

CASE 
	WHEN LOWER(order_status) LIKE '%deliver%' THEN 'Deliver'
	WHEN LOWER(order_status) LIKE '%return%' THEN 'Returned'
	WHEN LOWER(order_status) LIKE '%pend%' THEN 'Pending'
	WHEN LOWER(order_status) LIKE '%ship%' THEN 'Shipped'
	ELSE 'Other'
END AS cleaned_order_status

from Orders


-- STANDARDIZE PRODUCT NAME 

SELECT product_name,

CASE 
	WHEN LOWER(product_name) LIKE '%apple watch%' THEN 'Apple Watch'
	WHEN LOWER(product_name) LIKE '%google%' THEN 'Google Pixel'
	WHEN LOWER(product_name) LIKE '%macbook%' THEN 'Macbook Pro'
	WHEN LOWER(product_name) LIKE '%iphone%' THEN 'iPhone 14'
	WHEN LOWER(product_name) LIKE '%samsung%' THEN 'Samsung Galaxy S22'
	ELSE 'Other'

END AS cleaned_product_name
from Orders



-- CLEAN QUANTITY FIELD


SELECT DISTINCT quantity,
	CASE
		WHEN LOWER(quantity) = 'two' THEN 2
		ELSE CAST(quantity AS INT)

	END AS cleaned_quantity
from Orders;


-- 4 CLEAN THE CUSTOMER NAME FIELD 

CREATE FUNCTION dbo.InitCap (@Text NVARCHAR(4000))
RETURNS NVARCHAR(4000)
AS
BEGIN
    DECLARE @Result NVARCHAR(4000) = '';
    DECLARE @Word NVARCHAR(100);
    DECLARE @Pos INT;

    -- Loop through words separated by spaces
    WHILE LEN(@Text) > 0
    BEGIN
        SET @Pos = CHARINDEX(' ', @Text);

        IF @Pos = 0 
            SET @Pos = LEN(@Text) + 1;

        SET @Word = LEFT(@Text, @Pos - 1);

        SET @Result = @Result 
            + UPPER(LEFT(@Word, 1)) 
            + LOWER(SUBSTRING(@Word, 2, LEN(@Word))) 
            + ' ';

        SET @Text = LTRIM(SUBSTRING(@Text, @Pos + 1, LEN(@Text)));
    END

    RETURN RTRIM(@Result);
END;
GO
SELECT dbo.InitCap(customer_name) AS customer_name 
FROM Orders
WHERE customer_name IS NOT NULL ;


-- REMOVE DUPLICATED ORDERS 

SELECT *
FROM (
SELECT *,
    ROW_NUMBER() OVER(

    PARTITION BY LOWER(email), LOWER(product_name)
    ORDER BY order_id
    ) AS rn
FROM Orders
) AS t
WHERE rn = 1


-- FINAL CLEAN DATA 


DROP TABLE IF EXISTS dbo.Orders_Clean;

SELECT
    order_id,

    -- InitCap customer name
    dbo.InitCap(customer_name) AS customer_name,

    -- Normalize email
    LOWER(LTRIM(RTRIM(email))) AS email,

    order_date,

    -- Standardize product name
    CASE 
        WHEN LOWER(product_name) LIKE '%apple watch%' THEN 'Apple Watch'
        WHEN LOWER(product_name) LIKE '%google%'      THEN 'Google Pixel'
        WHEN LOWER(product_name) LIKE '%macbook%'     THEN 'Macbook Pro'
        WHEN LOWER(product_name) LIKE '%iphone%'      THEN 'iPhone 14'
        WHEN LOWER(product_name) LIKE '%samsung%'     THEN 'Samsung Galaxy S22'
        ELSE dbo.InitCap(product_name)
    END AS product_name,

    -- Clean quantity safely
    CASE
        WHEN LOWER(quantity) = 'two' THEN 2
        ELSE TRY_CAST(quantity AS INT)
    END AS quantity,

    price,

    -- Normalize country
    dbo.InitCap(country) AS country,

    -- Standardize order status
    CASE 
        WHEN LOWER(order_status) LIKE '%deliver%' THEN 'Delivered'
        WHEN LOWER(order_status) LIKE '%return%'  THEN 'Returned'
        WHEN LOWER(order_status) LIKE '%pend%'    THEN 'Pending'
        WHEN LOWER(order_status) LIKE '%ship%'    THEN 'Shipped'
        ELSE 'Other'
    END AS order_status,

    notes
INTO dbo.Orders_Clean
FROM dbo.Orders
WHERE order_id IS NOT NULL
  AND customer_name IS NOT NULL
  AND product_name IS NOT NULL
  AND price IS NOT NULL;



