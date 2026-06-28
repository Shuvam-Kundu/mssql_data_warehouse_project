/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/

IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.product_report AS
WITH base_query AS(
SELECT 
	p.product_key,
	p.product_name,
	p.category,
	p.subcatagory,
	p.cost,
	s.order_number,
	s.order_date,
	s.sales_amount,
	s.quantity,
	s.customer_key
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key),

product_aggregation AS (
SELECT 
	product_key,
	product_name,
	category,
	subcatagory,
	cost,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan,
	COUNT(order_number) AS total_order,
	SUM(sales_amount) AS total_sale_value,
	SUM(quantity) AS total_quantity_sold
FROM base_query
GROUP BY product_key,product_name,category,subcatagory,cost)

SELECT 
	product_key,
	product_name,
	category,
	subcatagory,
	cost,
	last_order_date,
	lifespan,
	CASE WHEN total_order < 100 THEN 'O1 group'
		 WHEN total_order BETWEEN 100 AND 1000 THEN 'O2 group'
		 WHEN total_order BETWEEN 1001 AND 2000 THEN 'O3 group'
		 WHEN total_order BETWEEN 2001 AND 3000 THEN 'O4 group'
		 ELSE 'O5 group'
	END AS product_order_category,
	CASE WHEN total_sale_value < 10000 THEN 'S1 group'
		 WHEN total_sale_value <= 100000 THEN 'S2 group'
		 WHEN total_sale_value <= 1000000 THEN 'S3 group'
		 ELSE 'S4 group'
	END AS sale_value_category,
	total_order,
	total_sale_value,
	total_quantity_sold,
	CAST(total_sale_value * 1.00 / total_order AS DECIMAL(10,1)) AS sale_per_order
FROM product_aggregation;


SELECT * FROM gold.product_report;
