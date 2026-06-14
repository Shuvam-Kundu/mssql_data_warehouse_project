/*
=================================================================================
CREATE DATABASE AND SCHEMAS
=================================================================================

Script purpose: 
  This script creates a new database named 'DataWarehouse' after checking if it already exists.
  If the database exists, it is dropped and recreated. Along withh that, the scripts creates three 
  schemas within the database: 'bronze', 'silver' and 'gold'

****WARNING****
***************
  Running this script will the entire database 'DataWarehouse' if it exists.
  All data in that databse will be permanently deleted. Proceed with caution
  ensure you have proper backup before running the script.

*/


USE master;
GO

-- Drop & recreate the 'Data Warehouse' database
 
IF EXISTS ( SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
	BEGIN 
		ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		DROP DATABASE DataWarehouse;
	END;
GO


-- Create database 'DataWarehouse'

CREATE DATABASE DataWarehouse;

GO

-- Create schema bronze, silver and gold schemas

CREATE SCHEMA bronze;

GO


CREATE SCHEMA silver;

GO


CREATE SCHEMA gold;

GO
