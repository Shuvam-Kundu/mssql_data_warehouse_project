/*
feat(bronze): add stored procedure for full data load
************************************************************************************************************
Stored Procedure: Load Bronze Layer (Source -> Bronze)
************************************************************************************************************
Purpose: This SP loads data into Bronze schema from the external source csv files.

Actions Performed: 1. Truncates the bronze tables
				   2. Uses the BULK INSERT command to load data from csv files to bronze tables.

Parameters: This SP does not takes any parameters and returns any value

Usage: EXEC bronze.load_bronze
************************************************************************************************************
*/



CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @start_time_ult DATETIME, @end_time_ult DATETIME;
	SET @start_time_ult = GETDATE();
	BEGIN TRY
-- FULL LOAD 'bronze.crm_cust_info'
		SET @start_time = GETDATE();
		TRUNCATE table bronze.crm_cust_info;

		BULK INSERT bronze.crm_cust_info
		FROM 'D:\Projects\SQL\SQL Data Warehouse Project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Loading time for "bronze.crm_cust_info": '+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+' seconds';


-- FULL LOAD 'bronze.crm_prd_info'

		SET @start_time = GETDATE();
		TRUNCATE table bronze.crm_prd_info;

		BULK INSERT bronze.crm_prd_info
		FROM 'D:\Projects\SQL\SQL Data Warehouse Project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Loading time for "bronze.crm_prd_info": '+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+' seconds';


-- FULL LOAD 'bronze.crm_sales_details'

		SET @start_time = GETDATE();
		TRUNCATE table bronze.crm_sales_details;

		BULK INSERT bronze.crm_sales_details
		FROM 'D:\Projects\SQL\SQL Data Warehouse Project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Loading time for "bronze.crm_sales_details": '+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+' seconds';


-- FULL LOAD 'bronze.erp_cust_az12'

		SET @start_time = GETDATE();
		TRUNCATE table bronze.erp_cust_az12;

		BULK INSERT bronze.erp_cust_az12
		FROM 'D:\Projects\SQL\SQL Data Warehouse Project\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Loading time for "bronze.erp_cust_az12": '+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+' seconds';


-- FULL LOAD 'bronze.erp_loc_a101'

		SET @start_time = GETDATE();
		TRUNCATE table bronze.erp_loc_a101;

		BULK INSERT bronze.erp_loc_a101
		FROM 'D:\Projects\SQL\SQL Data Warehouse Project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Loading time for "bronze.erp_loc_a101": '+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+' seconds';


-- FULL LOAD 'bronze.erp_px_cat_g1v2'

		SET @start_time = GETDATE();
		TRUNCATE table bronze.erp_px_cat_g1v2;

		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'D:\Projects\SQL\SQL Data Warehouse Project\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT 'Loading time for "bronze.erp_px_cat_g1v2": '+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR)+' seconds';

		SET @end_time_ult = GETDATE();
		PRINT 'Loading time for BRONZE LAYER ": '+CAST(DATEDIFF(SECOND,@start_time_ult,@end_time_ult) AS NVARCHAR)+' seconds';
	END TRY

	BEGIN CATCH
		PRINT 'Problem while loading BRONZE LAYER';
		PRINT 'Error Message: '+CAST(ERROR_MESSAGE() AS NVARCHAR);
		PRINT 'Error Message: '+CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message: '+CAST(ERROR_STATE() AS NVARCHAR);
	END CATCH
END
