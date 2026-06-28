/*
*******************************************************************************
Customer Report
*******************************************************************************
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
*******************************************************************************
*/

IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS
WITH base_query AS (
SELECT
	s.order_number,
	s.product_key,
	s.order_date,
	s.sales_amount,
	s.quantity,
	c.customer_key,
	c.customer_number,
	CONCAT(c.first_name,' ',c.last_name) AS customer_name,
	c.last_name,
	c.birthdate,
	DATEDIFF(YEAR,birthdate,GETDATE()) AS age
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
WHERE s.order_date IS NOT NULL),

customer_aggregation AS (
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) as total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan
FROM base_query
GROUP BY customer_key,customer_number,customer_name,age)

SELECT 
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		 WHEN lifespan >= 12 AND total_sales  <= 5000 THEN 'Regular' 
		 WHEN lifespan < 12 THEN 'New' 
		 ELSE 'Not Categorized'
	END AS customer_category,
	CASE WHEN age < 40 THEN 'Age group 1'
		 WHEN age BETWEEN 40 AND 60 THEN 'Age group 2'
		 WHEN age > 60 THEN 'Age group 3'
		 ELSE 'n/a'
	END AS age_group,
	CONCAT(DATEDIFF(MONTH,last_order_date,GETDATE()),' months') AS has_not_ordered_since,
	CASE WHEN total_orders = 0 THEN 0
		 ELSE total_sales / total_orders
	END AS avg_order_value,
	CASE WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan 
	END AS monthly_avg_spend
FROM customer_aggregation;

GO
