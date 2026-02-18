<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        04/05/2023	DK				Original script
        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This script will delete data for the Secondary Demographics file that is passed in

    
    .DESCRIPTION

        Given the filename, any data related to the Secondary Demographics file will be deleted
        from the appropriate Identifi Member database
    

    .PARAMETER filename

        Specify the connection string to the Azure database to connect to


    .PARAMETER client_key

        Specify the connection string to the Azure database to connect to


    .PARAMETER database_name

        Specify the connection string to the Azure database to connect to


    .PARAMETER user_id

        Specify the connection string to the Azure database to connect to


    .PARAMETER password

        Specify the connection string to the Azure database to connect to

    EXAMPLE
    .\Delete-SecondaryDemographicsFileData.ps1 -Server "aldqadbqr06" -Filename "CMT_MemDemoD_20230101.txt" -ClientKey "10606" -Database "mdsd-auto-001" -UserId "md_readwrite_user" -Password "QcjoFfdtimmKHP4by4HQ" -LogId "0" 


#>

[CmdletBinding()]
Param(

    [Parameter(Mandatory=$True)]
    [string]$Server,

    [Parameter(Mandatory=$True)]
    [string]$Filename,

    [Parameter(Mandatory=$True)]
    [string]$ClientKey,

    [Parameter(Mandatory=$True)]
    [string]$Database,

    [Parameter(Mandatory=$True)]
    [string]$UserId,

    [Parameter(Mandatory=$True)]
    [string]$Password,

    [Parameter(Mandatory=$True)]
    [int32]$LogId


)

#memberdomain-database-conn-str
#$ConnectionString = "Server=tcp:ipe1qa-hpss-001.database.windows.net,1433;Initial Catalog=mdsd-qa-001;Persist Security Info=False;User ID=user;Password=password;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
#$ConnectionString = "Server=tcp:ipe1qa-hpss-001.database.windows.net,1433;Initial Catalog=mdsd-auto-001;Persist Security Info=False;User ID=user;Password=password;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
#$ConnectionString = "Server=tcp:ipe1qa-hpss-001.database.windows.net,1433;Initial Catalog=mdsd-reg-001;Persist Security Info=False;User ID=user;Password=password;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"


$ConnectionString = "Server=tcp:ipe1qa-hpss-001.database.windows.net,1433;Initial Catalog=" + $Database + ";Persist Security Info=False;User ID=" + $UserId + ";Password=" + $Password + ";MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

#**************************************************************************************************
# Set the SQL commands to be executed
#**************************************************************************************************
$sql = "DECLARE @data_key		VARCHAR(100)
               ,@row_count		INT

       SELECT @data_key			= DF.DataFile_Key
         FROM dbo.DataFile		DF
        WHERE DF.FileName		= @filename
          AND DF.Client_Key		= @client_key

        --****************************************************************************************
        IF OBJECT_ID('tempdb.dbo.#raw_transactions') IS NOT NULL
	        BEGIN DROP TABLE #raw_transactions END

        CREATE TABLE #raw_transactions
              (raw_key			VARCHAR(100))

        IF OBJECT_ID('tempdb.dbo.#member_ids') IS NOT NULL
	        BEGIN DROP TABLE #member_ids END

        CREATE TABLE #member_ids
              (client_key		INT
	          ,member_id		VARCHAR(100))

        IF OBJECT_ID('tempdb.dbo.#results') IS NOT NULL
	        BEGIN DROP TABLE #results END

        CREATE TABLE #results
              (table_name		VARCHAR(200)
	          ,records			INT
              ,err_num          INT           DEFAULT(0)
              ,err_msg          INT           DEFAULT(''))

        --****************************************************************************************
        INSERT INTO #raw_transactions
              (raw_key)
        SELECT RT.RawTransaction_Key
          FROM RawTransaction		RT
         WHERE RT.DataFile_Key		= @data_key

        INSERT INTO #member_ids
              (client_key
	          ,member_id)
        SELECT @client_key
              ,RTI.Value
          FROM dbo.RawTransactionIndex	RTI
          JOIN #raw_transactions		RT
            ON RTI.RawTransaction_Key	= RT.raw_key
         WHERE RTI.Name					= 'Member_SubscriberId'

        --****************************************************************************************

        BEGIN TRY
	        BEGIN TRANSACTION

		        DELETE DA
		          FROM dbo.Demographic_Address	DA
		          JOIN #raw_transactions		RT
		            ON DA.RawTransaction_Key	= RT.raw_key

		        SELECT @row_count = @@ROWCOUNT
		        IF @row_count > 0 BEGIN INSERT INTO #results(table_name, records) VALUES ('Demographic_Address', @row_count) END

		        DELETE DF
		          FROM dbo.Demographic_FreeformElement	DF
		          JOIN #raw_transactions				RT
		            ON DF.RawTransaction_Key			= RT.raw_key

		        SELECT @row_count = @@ROWCOUNT
		        IF @row_count > 0 BEGIN INSERT INTO #results(table_name, records) VALUES ('Demographic_FreeformElement', @row_count) END

		        DELETE DM
		          FROM dbo.Demographic_MiscElement		DM
		          JOIN #raw_transactions				RT
		            ON DM.RawTransaction_Key			= RT.raw_key

		        SELECT @row_count = @@ROWCOUNT
		        IF @row_count > 0 BEGIN INSERT INTO #results(table_name, records) VALUES ('Demographic_MiscElement', @row_count) END


		        DELETE DP
		          FROM dbo.Demographic_Phone		DP
		          JOIN #raw_transactions			RT
		            ON DP.RawTransaction_Key		= RT.raw_key

		        SELECT @row_count = @@ROWCOUNT
		        IF @row_count > 0 BEGIN INSERT INTO #results(table_name, records) VALUES ('Demographic_Phone', @row_count) END

		        DELETE DA
		          FROM dbo.DemographicsAggregated	DA
		          JOIN #member_ids					M
		            ON DA.Client_Key				= M.client_key
		           AND DA.MemberID					= M.member_id

		        SELECT @row_count = @@ROWCOUNT
		        IF @row_count > 0 BEGIN INSERT INTO #results(table_name, records) VALUES ('DemographicsAggregated', @row_count) END

		        DELETE RTI
		          FROM dbo.RawTransactionIndex		RTI	
		          JOIN #raw_transactions			RT
		            ON RTI.RawTransaction_Key		= RT.raw_key

		        SELECT @row_count = @@ROWCOUNT
		        IF @row_count > 0 BEGIN INSERT INTO #results(table_name, records) VALUES ('RawTransactionIndex', @row_count) END

		        DELETE RT1
		          FROM dbo.RawTransaction			RT1
		          JOIN #raw_transactions			RT2
		            ON RT1.RawTransaction_Key		= RT2.raw_key
		
		        SELECT @row_count = @@ROWCOUNT
		        IF @row_count > 0 BEGIN INSERT INTO #results(table_name, records) VALUES ('RawTransaction', @row_count) END

		        DELETE DFL
		          FROM dbo.DataFileLog				DFL		  
		         WHERE DFL.DataFile_Key				= @data_key

		        SELECT @row_count = @@ROWCOUNT
		        IF @row_count > 0 BEGIN INSERT INTO #results(table_name, records) VALUES ('DataFileLog', @row_count) END

		        DELETE DF
		          FROM dbo.DataFile					DF	  
		         WHERE DF.DataFile_Key				= @data_key

		        SELECT @row_count = @@ROWCOUNT
		        IF @row_count > 0 BEGIN INSERT INTO #results(table_name, records) VALUES ('DataFile', @row_count) END

	        COMMIT TRANSACTION

        END TRY
        BEGIN CATCH
	        ROLLBACK TRANSACTION
            INSERT INTO #results(table_name, records, err_num, err_msg)
            SELECT ''
                  ,''
                  ,ERROR_NUMBER() err_num
                  ,ERROR_MESSAGE() err_msg

        END CATCH
        
        SELECT * FROM #results"

#**************************************************************************************************
# Get the type_id from the log_id
#**************************************************************************************************
#Create the connection to the proper server
$log_connection = New-Object System.Data.SqlClient.SqlConnection
$log_connection.ConnectionString = "Server=" + $Server + ";Database=QA;User ID=user;Password=password"
$log_connection.Open()

$type_command = New-Object System.Data.SqlClient.SqlCommand
$type_command.Connection = $log_connection
$type_command.CommandTimeout = 30
$type_command.CommandText = "SELECT type_id FROM FDLogType WHERE log_id = " + $LogId

$type_reader = $type_command.ExecuteReader()

if ($type_reader.HasRows)
{
    $type_reader.Read() >> $null
    $type_id = $type_reader.Item("type_id")
}

$type_reader.Close()

Write-Host $type_id
#**************************************************************************************************
# Create the connection and delete the data
#**************************************************************************************************
try
{
    $sql_conn = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
    $sql_conn.Open()

    $sql_cmd  = New-Object System.Data.SqlClient.SqlCommand
    $sql_cmd.Connection = $sql_conn
    $sql_cmd.CommandTimeout = 30
    $sql_cmd.CommandText = $sql

    $sql_cmd.Parameters.Add('@filename', $Filename) >> $null
    $sql_cmd.Parameters.Add('@client_key', $ClientKey) >> $null

    $sql_reader = $sql_cmd.ExecuteReader()

#**************************************************************************************************
# Log results of the delete
#**************************************************************************************************
    $log_command = New-Object System.Data.SqlClient.SqlCommand
    $log_command.CommandType = [System.Data.CommandType]::StoredProcedure
    $log_command.CommandText = "dbo.spFDAuto_LogTypeEvent"
    $log_command.Connection  = $log_connection

    $parameter_type    = $log_command.Parameters.Add("@type_id",      [Int])
    $parameter_table   = $log_command.Parameters.Add("@table_name",   [Data.SQLDBType]::VarChar, 8000)
    $parameter_records = $log_command.Parameters.Add("@record_count", [Data.SQLDBType]::Int)
    $parameter_status  = $log_command.Parameters.Add("@status",       [Data.SQLDBType]::VarChar, 8000)
    $parameter_err_num = $log_command.Parameters.Add("@err_num",      [Data.SQLDBType]::Int)
    $parameter_err_msg = $log_command.Parameters.Add("@err_msg",      [Data.SQLDBType]::VarChar, 8000)

    if ($sql_reader.HasRows)
    {
        while ($sql_reader.Read())
        {
            $table_name = $sql_reader.Item("table_name")
            $records    = $sql_reader.Item("records")
            $err_num    = $sql_reader.Item("err_num")  
            $err_msg    = $sql_reader.Item("err_msg")

            if($err_num -ne 0)
            {
                $status = "Error"
            }
            else
            {
                $status = "Deleted"
            }

            $parameter_type.Value    = $type_id
            $parameter_table.Value   = $table_name
            $parameter_records.Value = $records
            $parameter_status.Value  = $status
            $parameter_err_num.Value = $err_num
            $parameter_err_msg.Value = $err_msg

            $log_command.ExecuteNonQuery() >> $null
        }
    }
    else
    {
        Write-Host
        Write-Host "             No data found to delete"
    }

    $sql_reader.Close()
    $sql_conn.Close();

    $log_command.Dispose()
    $log_connection.Close()
}
catch
{
    Write-Host $_
}
