CREATE TABLE IF NOT EXISTS stores(
	Store_Id SERIAL PRIMARY KEY,
	Store_Name VARCHAR (355),
	Store_City VARCHAR (355),
	Store_Location VARCHAR (355),
	Store_Open_Date DATE	
);

SELECT * FROM stores;


CREATE TABLE IF NOT EXISTS inventory(
	Store_ID INTEGER,
	Product_ID INTEGER,
	Stock_On_Hand INTEGER
);

SELECT * FROM inventory;


CREATE TABLE IF NOT EXISTS sales(
	Sale_ID INTEGER PRIMARY KEY,
	Date DATE,
	Store_ID INTEGER,
	Product_ID INTEGER,
	Units INTEGER
);


SELECT * FROM sales;

CREATE TABLE IF NOT EXISTS products(
	Product_ID SERIAL PRIMARY KEY,
	Product_Name VARCHAR (355),
	Product_Category VARCHAR (250),
	Product_Cost VARCHAR,
	Product_Price VARCHAR
);


SELECT * FROM products;


UPDATE products 
	SET product_cost = SPLIT_PART(product_cost, '$', 2);


ALTER TABLE products
	ALTER COLUMN product_cost TYPE FLOAT USING (product_cost::FLOAT);
	
UPDATE products
	SET product_price = REPLACE(product_price, '$', '');
	
ALTER TABLE products
	ALTER COLUMN product_price TYPE FLOAT USING (product_price::FLOAT);
	
--Queations	
--1. Which product categories drive the biggest profits? Is this the same across store locations?

SELECT * FROM sales;
SELECT * FROM stores;
SELECT * FROM products;

CREATE VIEW product_with_the_biggest_pro
SELECT
    p.product_category,
    SUM((p.product_price - p.product_cost) * s.units) AS total_profit
FROM
    sales AS s
JOIN
    products AS p ON s.product_id = p.product_id
GROUP BY
    p.product_category
ORDER BY
    total_profit DESC
limit 1;

SELECT * FROM product_with_the_biggest_profit;
-- 'Toys' drives biggest profit among each product category	
		
	
-- For the total profits across stores locaations

SELECT
    p.product_category,
    st.store_location,
    SUM((p.product_price - p.product_cost) * s.units) AS total_profit
FROM
    sales AS s
JOIN
    products p ON s.product_id = p.product_id
JOIN
    stores AS st ON s.store_id = st.store_id
--WHERE p.product_category = 'Toys' 
GROUP BY
    p.product_category, st.store_location
ORDER BY
    p.product_category, total_profit DESC;

/*Based on the provided outcome from the query:

Art & Crafts:

Downtown: $444,320
Commercial: $155,461
Residential: $92,132
Airport: $61,441
Electronics:

Downtown: $502,490
Commercial: $287,574
Airport: $108,197
Residential: $103,176
Games:

Downtown: $378,421
Commercial: $146,296
Airport: $80,768
Residential: $68,508
Sports & Outdoors:

Downtown: $293,468
Commercial: $112,499
Residential: $60,358
Airport: $39,393
Toys:

Downtown: $630,029
Commercial: $225,034
Residential: $136,214
Airport: $88,250
Observations:

Highest Total Profits by Category:

Toys category has the highest total profits across all store locations, particularly in Downtown.
Electronics also contribute significantly, especially in Downtown.
Games category shows strong performance in Downtown.
Consistency Across Store Locations:

Downtown appears to be the most profitable location across most categories.
Commercial areas also contribute significantly, but profits may vary based on the product category.
Residential and Airport locations generally have lower profits compared to Downtown and Commercial areas.
Conclusion:

Based on the provided data, 
"Toys" is the product category that consistently drives the highest profits across store locations, 
with Downtown being the most lucrative location overall. 
The profitability varies across different store locations,
emphasizing the importance of understanding the product category 
and location dynamics for strategic decision-making
*/


--2. How much money is tied up in inventory at the toy stores? How long will it last?

SELECT * FROM stores;
SELECT * FROM inventory;
SELECT * FROM products;
SELECT * FROM sales;

CREATE VIEW tied_down_capital AS
SELECT 
	p.product_id,
	p.product_category,
	P.product_cost,
	i.stock_on_hand,
	(p.product_cost * i.stock_on_hand) AS Tied_down_capital
FROM products AS P
JOIN inventory AS i ON i.product_id = P.product_id
WHERE product_category = 'Toys';
--GROUP BY 1, 2, 3, 4


SELECT * FROM tied_down_capital;

SELECT
	product_category,
	SUM(product_cost) AS Total_product_cost_at_hand,
	SUM(stock_on_hand) AS Total_stock_on_hand_at_hand,
	SUM(tied_down_capital) AS Total_tied_down_capital
FROM 
	tied_down_capital
GROUP BY 1;


-- 2b How long will it last

CREATE VIEW Average_Units_Sales AS
SELECT AVG(Total_Units) FROM(
SELECT
	product_category,
	date,
	SUM(units) AS Total_Units
FROM
	sales S
		JOIN products P ON P.product_id = S.product_id
	WHERE P.product_category = 'Toys'
GROUP BY 1, 2);

--TOTAL TOYS STORES STOCK AT HAND 
CREATE VIEW Total_Toys_Stock_at_hand AS
SELECT
	product_category,
	SUM(stock_on_hand) AS total_stock
FROM 
	inventory I 
JOIN products P ON I.product_id = P.product_id
WHERE product_category = 'Toys'
GROUP BY 1;


SELECT 
	P.product_category,
	SUM(S.units) AS Total_Units,
	SUM(I.stock_on_hand) AS total_stock,
	SUM(I.stock_on_hand) / SUM(S.units) AS No_of_selling_days
FROM products P JOIN sales S ON P.product_id = S.product_id
	JOIN inventory I ON I.product_id = P.product_id
WHERE P.product_category = 'Toys'
GROUP BY 1
-- It will take the company a total number of 15days to sell the remaining stocks in 'Toys' stores

CREATE VIEW MONTHLY_RECORDS AS
SELECT 
	EXTRACT('Year' FROM S.date) AS YEAR,
	CASE WHEN EXTRACT('MONTH' FROM S.date) = 1 THEN 'JANUARY'
		WHEN EXTRACT('MONTH' FROM S.date) = 2 THEN 'FEBRUARY'
		WHEN EXTRACT('MONTH' FROM S.date) = 3 THEN 'MARCH'
		WHEN EXTRACT('MONTH' FROM S.date) = 4 THEN 'APRIL'
		WHEN EXTRACT('MONTH' FROM S.date) = 5 THEN 'MAY'
		WHEN EXTRACT('MONTH' FROM S.date) = 6 THEN 'JUNE'
		WHEN EXTRACT('MONTH' FROM S.date) = 7 THEN 'JULY'
		WHEN EXTRACT('MONTH' FROM S.date) = 8 THEN 'AUGUST'
		WHEN EXTRACT('MONTH' FROM S.date) = 9 THEN 'SEPTEMBER'
		WHEN EXTRACT('MONTH' FROM S.date) = 10 THEN 'OCTOBER'
		WHEN EXTRACT('MONTH' FROM S.date) = 11 THEN 'NOVEMBER'
		ELSE 'DECEMBER' END AS MONTHS,
		p.product_category,
		s.units
FROM products P JOIN sales S ON P.product_id = S.product_id
	
	
SELECT
	YEAR,
	MONTHS,
	SUM(units)
FROM monthly_records
WHERE product_category = 'Toys'
GROUP BY 1, 2
ORDER BY 3 DESC

	

--3. Are sales being lost with out-of-stock products at certain locations?

SELECT * FROM stores;
SELECT * FROM inventory;
SELECT * FROM products;
SELECT * FROM sales;


SELECT
	p.product_id,
	p.product_name,
	i.stock_on_hand
FROM
	products p JOIN inventory i ON i.product_id = p.product_id
WHERE stock_on_hand = 0;


SELECT 
	DISTINCT store_location,
	store_name
FROM stores;


SELECT
	store_location,
	store_name,
	Total_stock_on_hand,
	SUM(Total_Sales_location) AS Total_Sales_location,
	COUNT(product_name) AS No_of_products
FROM(
SELECT
	DISTINCT st.store_name,
	st.store_location,
	p.product_name,
	--p.product_price,
	(i.stock_on_hand) AS Total_stock_on_hand,
	SUM((s.units * p.product_price)) AS Total_Sales_location
FROM
	sales s
JOIN products P ON p.product_id = s.product_id
JOIN stores st on st.store_id = s.store_id
JOIN inventory i on i.product_id = P.product_id
GROUP BY 1, 2, 3, 4
ORDER BY 3 DESC)
WHERE Total_stock_on_hand = 0
GROUP BY 1, 2, 3
ORDER BY 4 DESC






SELECT
	store_location,
	store_name,
	SUM(Total_Sales_location) AS Total_Sales_location,
	COUNT(product_name) AS No_of_products
FROM(
SELECT
	DISTINCT st.store_name,
	st.store_location,
	p.product_name,
	--p.product_price,
	SUM((s.units * p.product_price)) AS Total_Sales_location
FROM
	sales s
JOIN products P ON p.product_id = s.product_id
JOIN stores st on st.store_id = s.store_id
GROUP BY 1, 2, 3
ORDER BY 3 DESC)
GROUP BY 1, 2
ORDER BY 3 DESC