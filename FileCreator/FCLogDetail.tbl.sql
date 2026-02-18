IF OBJECT_ID('fw.FCLogDetail','U') IS NOT NULL
	BEGIN DROP TABLE fw.FCLogDetail END
GO
/**************************************************************************************************
Name:       FCLogDetail table
Purpose:    Table used to log FileCreator activity

Date        User        Change
---------------------------------------------------------------------------------------------
03/12/2020	DK			Original procedure

---------------------------------------------------------------------------------------------

***************************************************************************************************/
CREATE TABLE fw.FCLogDetail
      (log_id			INT	
	  ,date_time		DATETIME
	  ,test_case		VARCHAR(200)
	  ,method			VARCHAR(200)
	  ,filename			VARCHAR(8000)
	  ,folder			VARCHAR(8000)
	  ,expected_records	INT
	  ,actual_records	INT
	  ,status			VARCHAR(300)
	  ,err_num			INT
	  ,err_msg			VARCHAR(8000)
	  ,log_sid			INT				IDENTITY(1,1))

GO