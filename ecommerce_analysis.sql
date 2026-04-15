-- Project: E-commerce Orders Analysis
-- Author: Wyatt Chesser
-- Description: Analysis of revenue, retruns, and shipping performance

-- ========================================
-- 1. JOIN TEST
-- ========================================
-- Goal: Make sure tables connect correctly

SELECT
	o.order_id,
	p.product_name,
	o.price,
	o.quantity
FROM orders o
JOIN products p 
	ON o.product_id = p.product_id
LIMIT 10;

-- ========================================
-- 2. TOTAL REVENUE BY PRODUCT
-- ========================================
-- Goal: Calculate total revenue by product to identify which product generates the most revenue

SELECT
	p.product_name,
	ROUND(SUM(o.price * o.quantity * (1 - o.discount)), 2) AS revenue
FROM orders o
JOIN products p
	ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC;

-- ========================================
-- 3. TOP 5 PRODUCTS 
-- ========================================
-- Goal: Calculate quantity of each product to determine the top 5 products based on total units

SELECT	
	p.product_name,
	SUM(o.quantity) AS total_units
FROM orders o
JOIN products p
	ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_units DESC
LIMIT 5;

-- ========================================
-- 4. TOTAL REVENUE BY PRODUCT CATEGORY
-- ========================================
-- Goal: Calculate total revenue by product category to identify top-performing category

SELECT
	p.product_category,
	ROUND(SUM(o.price * o.quantity * (1 - o.discount)), 2) AS revenue
FROM orders o
JOIN products p 
	ON o.product_id = p.product_id
GROUP BY p.product_category
ORDER BY revenue DESC;

-- ========================================
-- 5. SHIPPING PERFORMANCE
-- ========================================
-- Goal: Calculate the average number of shipping days for each product category

SELECT	
	p.product_category,
	ROUND(AVG(julianday(o.shipping_date) - julianday(o.order_date)), 2) AS avg_shipping_days
FROM orders o
JOIN products p
	ON o.product_id = p.product_id
GROUP BY p.product_category
ORDER BY avg_shipping_days DESC;

-- ========================================
-- 6. RETURN RATE
--========================================
-- Goal: Calculate the percent rate at which each product is returned based on total orders

SELECT 
	p.product_name,
	COUNT(*) AS total_orders,
	SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) AS returns,
	ROUND(
		100.0 * SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) / COUNT (*),
		2
	) AS return_rate_pct
FROM orders o
JOIN products p
	ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY return_rate_pct DESC;

-- ========================================
-- 7. PRODUCTS WITH NO orders
-- ========================================
-- Goal: Find out which products have not been ordered

SELECT 
	p.product_name,
	p.product_category
FROM products p
LEFT JOIN orders o
	ON p.product_id = o.product_id
WHERE o.order_id IS NULL;

-- ========================================
-- 8. PROFIT ANALYSIS
-- ========================================
-- Goal: Calculate the profit of each product by subtracting the cost from the revenue

SELECT	
	p.product_name,
	ROUND(SUM(o.price * o.quantity * (1 - o.discount)), 2) AS revenue,
	ROUND(SUM(p.cost * o.quantity), 2) AS cost,
	ROUND(SUM((o.price * (1 - o.discount) - p.cost) * o.quantity), 2) AS profit
FROM orders o
JOIN products p 
	ON p.product_id = o.product_id
GROUP BY p.product_name
ORDER BY profit DESC;

-- ========================================
-- 9. DISCOUNT VS RETURNS
-- ========================================
-- Goal: Find the correlation between the level of discount and the rate of returns

SELECT
	CASE
		WHEN discount < 0.10 THEN 'Low'
		WHEN discount < 0.20 THEN 'Medium'
		ELSE 'High'
	END AS discount_level,
	COUNT(*) AS orders,
	SUM(CASE WHEN order_status = 'Returned' THEN 1 ELSE 0 END) AS returns,
	ROUND(
		100.0 * SUM(CASE WHEN order_status = 'Returned' THEN 1 ELSE 0 END) / COUNT(*),
		2
	) AS return_rate
FROM orders
GROUP BY discount_level
ORDER BY return_rate DESC;
		


	