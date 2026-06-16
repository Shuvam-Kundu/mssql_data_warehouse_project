CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN
	DECLARE @start_time_ult DATETIME2, @end_time_ult DATETIME2, @start_time DATETIME2, @end_time DATETIME2;
	SET @start_time_ult = GETDATE();

	BEGIN TRY 
		SET @start_time = GETDATE();
--FULL LOAD silver.crm_cust_info

		PRINT 'Truncate "silver.crm_cust_info"';

		TRUNCATE TABLE silver.crm_cust_info;


		PRINT 'Loading "silver.crm_cust_info"';

		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date)

		SELECT cst_id, TRIM(cst_key) AS cst_key, TRIM(cst_firstname) AS cst_firstname,
		TRIM(cst_lastname) AS cst_lastname,
		CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			 WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
			 ELSE 'n/a' 
		END AS cst_marital_status,
		CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			 WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			 ELSE 'n/a' 
		END AS cst_gndr,
		cst_create_date
		FROM (

		SELECT *,
		ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flagging
		FROM bronze.crm_cust_info WHERE cst_id IS NOT NULL) T

		WHERE flagging = 1;

		SET @end_time = GETDATE();

		PRINT 'Loading time for "silver.crm_cust_info" is: '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+' seconds';


--FULL LOAD silver.crm_prd_info

		SET @start_time = GETDATE();

		PRINT 'Truncate silver.crm_prd_info';

		TRUNCATE TABLE silver.crm_prd_info;


		PRINT 'Loading silver.crm_prd_info';



		INSERT INTO silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
			SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
			TRIM(prd_nm) AS prd_nm,
			ISNULL(prd_cost,0) AS prd_cost,
			CASE UPPER(TRIM(prd_line)) 
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'T' THEN 'Touring'
				WHEN 'S' THEN 'Others' 
				ELSE 'n/a'
			END AS prd_line,
			prd_start_dt,
			CAST(LEAD(prd_start_dt,1) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) -1 AS DATE) as prd_end_dt
		FROM bronze.crm_prd_info;

		SET @end_time = GETDATE();

		PRINT 'Loading time for "silver.crm_prd_info" is: '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+' seconds';


--FULL LOAD silver.crm_sales_details

		SET @start_time = GETDATE();

		PRINT 'Truncate silver.crm_sales_details';

		TRUNCATE TABLE silver.crm_sales_details;


		PRINT 'Loading silver.crm_sales_details';


		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) !=8 THEN NULL
				 ELSE CAST(CAST(sls_order_dt AS NVARCHAR) AS DATE)
			END AS sls_order_dt,
				CASE WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) !=8 THEN NULL
				 ELSE CAST(CAST(sls_ship_dt AS NVARCHAR) AS DATE)
			END AS sls_ship_dt,
				CASE WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) !=8 THEN NULL
				 ELSE CAST(CAST(sls_due_dt AS NVARCHAR) AS DATE)
			END AS sls_due_dt,
			CASE WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != ABS(sls_quantity) * ABS (sls_price)
							THEN ABS(sls_quantity) * ABS (sls_price)
				 ELSE sls_sales 
			END AS sls_sales,
			sls_quantity,
			CASE WHEN sls_price <= 0 OR sls_price IS NULL
							THEN ABS(sls_sales)/NULLIF(sls_quantity,0)
				 ELSE sls_price 
			END AS sls_price
		FROM bronze.crm_sales_details;

		SET @end_time = GETDATE();

		PRINT 'Loading time for "silver.crm_sales_details" is: '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+' seconds';



--FULL LOAD silver.erp_cust_az12

		SET @start_time = GETDATE();

		PRINT 'Truncate silver.erp_cust_az12';

		TRUNCATE TABLE silver.erp_cust_az12;


		PRINT 'Loading silver.erp_cust_az12';


		INSERT INTO silver.erp_cust_az12(
			cid,
			bdate,
			gen
			)

		SELECT  
		CASE WHEN cid LIKE ('%NAS%') THEN SUBSTRING(cid,4,LEN(cid))
					 ELSE cid
			 END AS cid,
			 CASE WHEN bdate > GETDATE() THEN NULL
					 ELSE bdate
			 END AS bdate,
			 CASE WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
				  WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
				  ELSE 'n/a'
			 END AS gen
		FROM bronze.erp_cust_az12;

		SET @end_time = GETDATE();

		PRINT 'Loading time for "silver.erp_cust_az12" is: '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+' seconds';



--FULL LOAD silver.erp_loc_a101

		SET @start_time = GETDATE();

		PRINT 'Truncate silver.erp_loc_a101';

		TRUNCATE TABLE silver.erp_loc_a101;


		PRINT 'Loading silver.erp_loc_a101';


		INSERT INTO silver.erp_loc_a101(
			cid,
			cntry
			)

		SELECT  
			REPLACE(cid,'-','') AS cid,
			CASE WHEN UPPER(TRIM(cntry)) IN ('USA','US') THEN 'United States'
				 WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
				 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
				 ELSE cntry
			END AS cntry
		FROM bronze.erp_loc_a101;

		SET @end_time = GETDATE();

		PRINT 'Loading time for "silver.erp_loc_a101" is: '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+' seconds';



--FULL LOAD silver.erp_px_cat_g1v2

		SET @start_time = GETDATE();

		PRINT 'Truncatate silver.erp_px_cat_g1v2';

		TRUNCATE TABLE silver.erp_px_cat_g1v2;


		PRINT 'Loading silver.erp_px_cat_g1v2';

		INSERT INTO silver.erp_px_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance
			)

		SELECT  id,
				cat,
				subcat,
				maintenance
			FROM bronze.erp_px_cat_g1v2;

		SET @end_time = GETDATE();

		PRINT 'Loading time for "silver.erp_px_cat_g1v2" is: '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+' seconds';

		SET @end_time_ult = GETDATE()
		PRINT 'Loading time for SILVER LAYER ": '+CAST(DATEDIFF(SECOND,@start_time_ult,@end_time_ult) AS NVARCHAR)+' seconds';
	END TRY

	BEGIN CATCH
		PRINT 'Problem while loading SILVER LAYER';
		PRINT 'Error Message: '+CAST(ERROR_MESSAGE() AS NVARCHAR);
		PRINT 'Error Message: '+CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message: '+CAST(ERROR_STATE() AS NVARCHAR);
	END CATCH
END 




