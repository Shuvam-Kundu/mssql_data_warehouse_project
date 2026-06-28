/*
*******************************************************************************
DDL Script: Create Gold Views
*******************************************************************************
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
********************************************************************************
*/

--here we generated surrogated key with window FUNCTION

--as the gender column of CRM and ERP table had mistmatcn with the switch case we ensure the priority goes to CRM and if n/a or is present in CRM then priority goes to ERP and if ERP has NULL the it
will have 'n/a'

--we also renamed the columns for end business users

IF OBJECT_ID ('gold.dim_customers','V') IS NOT NULL
DROP VIEW gold.dim_customers;

GO


CREATE VIEW gold.dim_customers AS 

SELECT 
	ROW_NUMBER() OVER(ORDER BY cci.cst_id) AS customer_key,
	cci.cst_id AS customer_id,
	cci.cst_key AS customer_number,
	cci.cst_firstname AS first_name,
	cci.cst_lastname AS last_name,
	eca.bdate AS birthdate,
	CASE WHEN cci.cst_gndr != 'n/a' THEN cci.cst_gndr
		 ELSE COALESCE(eca.gen,'n/a')
	END AS gender,
	cci.cst_marital_status,
	ela.cntry AS country,
	cci.cst_create_date
FROM silver.crm_cust_info cci
LEFT JOIN silver.erp_cust_az12 eca ON cci.cst_key = eca.cid
LEFT JOIN silver.erp_loc_a101 ela ON cci.cst_key = ela.cid;


select * from gold.dim_customer



--here we have generated a similar surrogated key based on crm start date and product_key
--we are taking the records from crm prd info table where end_date is null this signifies records which have no end_date means they are active ones. and business does need to know their history now

IF OBJECT_ID ('gold.dim_products','V') IS NOT NULL
DROP VIEW gold.dim_products;

GO


CREATE VIEW gold.dim_products AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY cpi.prd_start_dt, cpi.prd_key) AS product_key,
	cpi.prd_id AS product_id,
	cpi.prd_key AS product_number,
	cpi.prd_nm AS product_name,
	cpi.cat_id AS category_id,
	epcg.cat AS category,
	epcg.subcat AS subcatagory,
	epcg.maintenance,
	cpi.prd_cost AS cost,
	cpi.prd_line AS product_line,
	cpi.prd_start_dt AS start_date
FROM silver.crm_prd_info cpi
LEFT JOIN silver.erp_px_cat_g1v2 epcg 
ON cpi.cat_id = epcg.id
WHERE cpi.prd_end_dt IS NULL;


select * from gold.dim_products;



--we have done silver.crm_sales_details csd LEFT JOIN gold.dim_products gdp AND also >> silver.crm_sales_details csd LEFT JOIN gold.dim_customer gdc
--to use foreign key relation between 2 silver tables and 1 golde view.

IF OBJECT_ID ('gold.fact_sales','V') IS NOT NULL
DROP VIEW gold.fact_sales;

GO

CREATE VIEW gold.fact_sales AS

SELECT 
	csd.sls_ord_num AS order_number,
	gdp.product_key,
	gdc.customer_key,
	csd.sls_order_dt AS order_date,
	csd.sls_ship_dt AS shipping_date,
	csd.sls_due_dt AS due_date,
	csd.sls_sales AS sales_amount,
	csd.sls_quantity AS quantity,
	csd.sls_price AS price
FROM silver.crm_sales_details csd
LEFT JOIN gold.dim_products gdp
ON csd.sls_prd_key = gdp.product_number
LEFT JOIN gold.dim_customers gdc
ON csd.sls_cust_id = gdc.customer_id;


select * from gold.fact_sales
