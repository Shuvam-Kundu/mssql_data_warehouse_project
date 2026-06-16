------------------------------------BRONZE TABLE DATA CHECKS AS WE NEED TO TO DATA TRANSFORMATIONS---------------------------

--CHECKING IF THERE IS DUPLICATES OR NULL IN PK
SELECT * FROM (
SELECT cst_id, COUNT(*) as REPEATATIONS FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id = NULL) t;




--KEEPING ONLY CST_ID WHICH ARE NOT DUPLICATED OR NULL
SELECT * FROM (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flagging
FROM bronze.crm_cust_info WHERE cst_id IS NOT NULL) T
WHERE flagging = 1;




--CHECKING IF THE VALUES FOR GENDER OR MARITAL STATUS COLUMN WITH EXTRA SPACES
SELECT cst_id, cst_firstname FROM bronze.crm_cust_info
WHERE TRIM(cst_firstname) != cst_firstname;

SELECT cst_id, cst_lastname FROM bronze.crm_cust_info
WHERE TRIM(cst_lastname) != cst_lastname;




--CHECKING HOW MANY TYPES OF GENDER ARE THERE
SELECT DISTINCT(cst_gndr) FROM bronze.crm_cust_info;





--CHECKING HOW MANY TYPES OF MARITIAL STATUS ARE THERE
SELECT DISTINCT(cst_marital_status) FROM bronze.crm_cust_info;

----------------------------DATA CHECKS FOR silver.crm_cust_info ONCE WE HAVE CREATED IT--------------------------


--CHECKING IF THERE IS DUPLICATES OR NULL IN PK
SELECT * FROM (
SELECT cst_id, COUNT(*) as REPEATATIONS FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id = NULL) t;




--KEEPING ONLY CST_ID WHICH ARE NOT DUPLICATED OR NULL
SELECT * FROM (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flagging
FROM silver.crm_cust_info WHERE cst_id IS NOT NULL) T
WHERE flagging = 1;




--CHECKING IF THE VALUES FOR GENDER OR MARITAL STATUS COLUMN WITH EXTRA SPACES
SELECT cst_id, cst_firstname FROM silver.crm_cust_info
WHERE TRIM(cst_firstname) != cst_firstname;

SELECT cst_id, cst_lastname FROM silver.crm_cust_info
WHERE TRIM(cst_lastname) != cst_lastname;




--CHECKING HOW MANY TYPES OF GENDER ARE THERE
SELECT DISTINCT(cst_gndr) FROM bronze.crm_cust_info;





--CHECKING HOW MANY TYPES OF MARITIAL STATUS ARE THERE
SELECT DISTINCT(cst_marital_status) FROM bronze.crm_cust_info;


SELECT * FROM silver.crm_cust_info;



--**************************************************************************************************************************************************************************************


----------------------------------VALIDATION FROM SOURCE bronze.crm_prd_info----------------------------------------


--CHECKING IF THERE IS DUPLICATES OR NULL IN PK
SELECT * FROM (
SELECT prd_id, COUNT(*) as REPEATATIONS FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id = NULL) t;



--CHECKING IF THERE ARE PRODUCTS WITH NEGATIVE OR NULL COST
SELECT * FROM bronze.crm_prd_info WHERE  prd_cost < 0 OR prd_cost IS NULL;



--CHECKING HOW MANY TYPES OF PRD_LINE ARE THERE
SELECT DISTINCT(prd_line) FROM bronze.crm_prd_info;



--CHECKING IF THERE ARE ANY PRD_LINE VALUES WITH EXTRA SPACES
SELECT * FROM bronze.crm_prd_info WHERE TRIM(prd_line) != prd_line;




--CHECKING IF THERE ARE ANY VALUES WHERE END_DATE < START_DATE
SELECT * FROM bronze.crm_prd_info WHERE prd_start_dt > prd_end_dt;


--------------------------------VALIDATING silver.crm_prd_info data---------------------------------------

--CHECKING IF THERE IS DUPLICATES OR NULL IN PK
SELECT * FROM (
SELECT prd_id, COUNT(*) as REPEATATIONS FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id = NULL) t;



--CHECKING IF THERE ARE PRODUCTS WITH NEGATIVE OR NULL COST
SELECT * FROM silver.crm_prd_info WHERE  prd_cost < 0 OR prd_cost IS NULL;



--CHECKING HOW MANY TYPES OF PRD_LINE ARE THERE
SELECT DISTINCT(prd_line) FROM silver.crm_prd_info;



--CHECKING IF THERE ARE ANY PRD_LINE VALUES WITH EXTRA SPACES
SELECT * FROM silver.crm_prd_info WHERE TRIM(prd_line) != prd_line;




--CHECKING IF THERE ARE ANY VALUES WHERE END_DATE < START_DATE
SELECT * FROM silver.crm_prd_info WHERE prd_start_dt > prd_end_dt;





--***********************************************************************************



--------------------------------------------------validating bronze.crm_sales_details-------------------------------------------------------------------------


--CHECKING IF sls_prd_key IS WORKING FINE AS FK
SELECT * FROM bronze.crm_sales_details WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info) ;


--CHECKING IF sls_cust_id IS WORKING FINE AS FK
SELECT * FROM bronze.crm_sales_details WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info) ;



--CHECKING IF THERE ARE ANY SLS_ORD_NUM VALUES WITH EXTRA SPACES
SELECT * FROM bronze.crm_sales_details WHERE TRIM(sls_ord_num) != sls_ord_num;



--CHECKING IF THERE ARE ANY SLS_PRD_KEY VALUES WITH EXTRA SPACES
SELECT * FROM bronze.crm_sales_details WHERE TRIM(sls_prd_key) != sls_prd_key;


--CHECKING IF ANY VALUES WITH INVALID ORDER_DATE
SELECT * FROM bronze.crm_sales_details WHERE sls_order_dt <= 0 OR LEN(sls_order_dt) !=8;

--CHECKING IF ANY VALUES WITH INVALID SHIP_DATE
SELECT * FROM bronze.crm_sales_details WHERE sls_ship_dt <= 0 OR LEN(sls_ship_dt) !=8;

--CHECKING IF ANY VALUES WITH INVALID DUE_DATE
SELECT * FROM bronze.crm_sales_details WHERE sls_due_dt <= 0 OR LEN(sls_due_dt) !=8;

--CHECKING IF THERE ARE ANY VALUES WHERE SLS_ORDER_DT > SLS_SHIP_DT OR SLS_ORDER_DT > SLS_DUE_DT
SELECT * FROM bronze.crm_sales_details WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;


--CHECKING WRONG CALCULATED SALES,QUANTIT AND PRICE RELATION
--SALES = QUANTITY*PRICE (ALWAYS)
--PRICE IS ALWAYS +
SELECT DISTINCT sls_sales, sls_quantity, sls_price  FROM bronze.crm_sales_details 
WHERE sls_sales != (sls_quantity) * ABS(sls_price) OR
sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0 OR
sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
ORDER BY sls_sales, sls_quantity, sls_price;




--CHECKING IF THERE ARE ANY SLS_ORD_NUM VALUES WITH EXTRA SPACES
SELECT * FROM silver.crm_sales_details WHERE TRIM(sls_ord_num) != sls_ord_num;



--CHECKING IF THERE ARE ANY SLS_PRD_KEY VALUES WITH EXTRA SPACES
SELECT * FROM silver.crm_sales_details WHERE TRIM(sls_prd_key) != sls_prd_key;



--CHECKING IF THERE ARE ANY VALUES WHERE SLS_ORDER_DT > SLS_SHIP_DT OR SLS_ORDER_DT > SLS_DUE_DT
SELECT * FROM silver.crm_sales_details WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;


--CHECKING WRONG CALCULATED SALES,QUANTIT AND PRICE RELATION
--SALES = QUANTITY*PRICE (ALWAYS)
--PRICE IS ALWAYS +
SELECT DISTINCT sls_sales, sls_quantity, sls_price  FROM silver.crm_sales_details 
WHERE sls_sales != (sls_quantity) * ABS(sls_price) OR
sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0 OR
sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
ORDER BY sls_sales, sls_quantity, sls_price;


--******************************************************************************


--CHECKING IF THERE ARE ANY SLS_ORD_NUM VALUES WITH EXTRA SPACES
SELECT * FROM silver.crm_sales_details WHERE TRIM(sls_ord_num) != sls_ord_num;



--CHECKING IF THERE ARE ANY SLS_PRD_KEY VALUES WITH EXTRA SPACES
SELECT * FROM silver.crm_sales_details WHERE TRIM(sls_prd_key) != sls_prd_key;



--CHECKING IF THERE ARE ANY VALUES WHERE SLS_ORDER_DT > SLS_SHIP_DT OR SLS_ORDER_DT > SLS_DUE_DT
SELECT * FROM silver.crm_sales_details WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;


--CHECKING WRONG CALCULATED SALES,QUANTIT AND PRICE RELATION
--SALES = QUANTITY*PRICE (ALWAYS)
--PRICE IS ALWAYS +
SELECT DISTINCT sls_sales, sls_quantity, sls_price  FROM silver.crm_sales_details 
WHERE sls_sales != (sls_quantity) * ABS(sls_price) OR
sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0 OR
sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
ORDER BY sls_sales, sls_quantity, sls_price;


--******************************************************************************



------------------------------------------------------validating the bronze.erp_cust_az12 table-------------------------------------

--CHECKING IF THERE ARE ANY BDAY WHICH ARE GREATEDR THEN CURRENT DATE
SELECT * FROM bronze.erp_cust_az12 WHERE bdate > GETDATE();

--CHECKING IF DISTINCT GENDER 
SELECT DISTINCT gen FROM bronze.erp_cust_az12 ;


--------------------------------------------------validating the silver.erp_cust_az12 table-------------------------------------

--CHECKING IF THERE ARE ANY BDAY WHICH ARE GREATEDR THEN CURRENT DATE
SELECT * FROM silver.erp_cust_az12 WHERE bdate > GETDATE();

--CHECKING IF DISTINCT GENDER 
SELECT DISTINCT gen FROM silver.erp_cust_az12 ;

-----------**************************************************************************************************************************************************************



---------------------validating bronze.erp_loc_a101 table-----------------------------------------------------------------------------------

--CHECKING IF THE JOIN WILL WORK CORRECTLY; LATER USE THIS TYPE OF QUERIES FPR ALL RELATED TABLESPACE
SELECT cst_key FROM silver.crm_cust_info WHERE cst_key NOT IN (
SELECT  
	REPLACE(cid,'-','') AS cid
FROM bronze.erp_loc_a101) 



--CHECKING IF DISTINCT COUNTRIES
SELECT DISTINCT cntry FROM bronze.erp_loc_a101 ;


---------------------------validating silver.erp_loc_a101 table-----------------------------------------------------------------------------------

--CHECKING IF DISTINCT COUNTRIES
SELECT DISTINCT cntry FROM silver.erp_loc_a101 ;


--********************************************************************************************



-------------------------------------------validating bronze.erp_px_cat_g1v2 table---------------------------------------------------




--CHECKING IF COLUMN CAT, SUBCAT, MAINTENANCE HAS ANY VALUES WITH EXTRA SPACES
SELECT * FROM bronze.erp_px_cat_g1v2 WHERE TRIM(cat) != cat;


--CHECKING IF COLUMN SUBCAT, MAINTENANCE HAS ANY VALUES WITH EXTRA SPACES
SELECT * FROM bronze.erp_px_cat_g1v2 WHERE TRIM(subcat) != subcat;


--CHECKING IF COLUMN MAINTENANCE HAS ANY VALUES WITH EXTRA SPACES
SELECT * FROM bronze.erp_px_cat_g1v2 WHERE TRIM(maintenance) != maintenance;


--CHECKING DISTINCT CAT 
SELECT DISTINCT cat FROM bronze.erp_px_cat_g1v2;

--CHECKING DISTINCT SUBCAT 
SELECT DISTINCT subcat FROM bronze.erp_px_cat_g1v2;


--CHECKING DISTINCT MAINTENANCE 
SELECT DISTINCT maintenance FROM bronze.erp_px_cat_g1v2;






