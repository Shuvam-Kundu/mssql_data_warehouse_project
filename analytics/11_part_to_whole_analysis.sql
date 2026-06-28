/*
*******************************************************************************
Part-to-Whole Analysis
*******************************************************************************
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
********************************************************************************
*/
-- Which categories contribute the most to overall sales?
SELECT
	category,
	sales,
	CONCAT(ROUND(CAST(sales AS FLOAT)/ total_sale * 100,2),'%') AS contribution FROM (
SELECT 
	*,
	SUM(sales) OVER() AS total_sale
FROM (
SELECT
	p.category,
	SUM(s.sales_amount) AS sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
GROUP BY p.category) t) p;
