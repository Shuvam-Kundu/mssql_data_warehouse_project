--DATA SEGMENTATION

--checking prod's cost range group
SELECT 
	COUNT (*), cost_group
FROM (
SELECT
	product_name,
	product_number,
	CASE WHEN cost BETWEEN 0 and 700 THEN 'Low cost group'
		 WHEN cost BETWEEN 701 and 1400 THEN 'Mid cost group'
		 WHEN cost BETWEEN 1401 AND 2100 THEN 'High cost group'
		 ELSE 'Ultra high cost group'
	END AS cost_group
FROM gold.dim_products) t
GROUP BY cost_group;


--categorizing customer

WITH customer_group AS (
SELECT 
	c.customer_key,
	SUM(s.sales_amount) AS total_sale,
	MIN(s.order_date) AS first_date,
	MAX(s.order_date) AS last_date,
	DATEDIFF(MONTH,MIN(s.order_date),MAX(s.order_date)) AS life_span,
	CASE WHEN DATEDIFF(MONTH,MIN(s.order_date),MAX(s.order_date)) >= 12 AND SUM(s.sales_amount) > 5000 THEN 'VIP'
		 WHEN DATEDIFF(MONTH,MIN(s.order_date),MAX(s.order_date)) >= 12 AND SUM(s.sales_amount) <= 5000 THEN 'Regular' 
		 WHEN DATEDIFF(MONTH,MIN(s.order_date),MAX(s.order_date)) < 12 THEN 'New' 
		 ELSE 'Not Categorized'
	END AS customer_category
FROM gold.dim_customers c
LEFT JOIN gold.fact_sales s
ON c.customer_key = s.customer_key
GROUP BY c.customer_key)

SELECT customer_category, COUNT(*) FROM customer_group GROUP BY customer_category;
