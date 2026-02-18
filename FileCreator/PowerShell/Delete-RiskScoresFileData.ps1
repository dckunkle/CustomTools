<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        04/019/2023	DK				Original script
        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This script will delete data for the Risk Scores file that is passed in

    
    .DESCRIPTION

        Given the filename, any data related to the Risk Scores file will be deleted
        from the appropriate Identifi Member database
    
    .PARAMETER Server

        The name of the server where the SQL database is located


    .PARAMETER Filename

        The file name pattern to look for when deleting files


    .PARAMETER ClientKey

        The client key specifying which client data to delete


    .PARAMETER Database

        The name of the database where the Risk Score data resides


    .PARAMETER UserId

        The user ID to use to connect to the database


    .PARAMETER Password

        Password used to connect to the database


    .PARAMETER LogId

        The log_id to log this delete activity


    EXAMPLE
    .\Delete-RiskScoresFileData.ps1 -Server "aldqadbqr06" -Filename "FC_RiskScores_20230414.txt" -ClientKey "10606" -Database "mdsd-auto-001" -UserId "md_readwrite_user" -Password "QcjoFfdtimmKHP4by4HQ" -LogId "0" 


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
#$ConnectionString = "Server=tcp:ipe1qa-hpss-001.database.windows.net,1433;Initial Catalog=mdsd-qa-001;Persist Security Info=False;User ID=md_readwrite_user;Password=HZB4XYxgBVPAxXoc5N6o;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
#$ConnectionString = "Server=tcp:ipe1qa-hpss-001.database.windows.net,1433;Initial Catalog=mdsd-auto-001;Persist Security Info=False;User ID=md_readwrite_user;Password=QcjoFfdtimmKHP4by4HQ;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
#$ConnectionString = "Server=tcp:ipe1qa-hpss-001.database.windows.net,1433;Initial Catalog=mdsd-reg-001;Persist Security Info=False;User ID=md_readwrite_user;Password=rguvlGlfHnFbwbWYTbh1;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"


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
        IF OBJECT_ID('tempdb.dbo.#results') IS NOT NULL
	        BEGIN DROP TABLE #results END

        CREATE TABLE #results
              (table_name		VARCHAR(200)
	          ,records			INT
              ,err_num          INT           DEFAULT(0)
              ,err_msg          INT           DEFAULT(''))

        --****************************************************************************************

        BEGIN TRY
	        BEGIN TRANSACTION

		        DELETE RS
		          FROM dbo.RiskScore			    RS
                 WHERE Client_Key                   = @client_key
		
		        SELECT @row_count = @@ROWCOUNT
		        IF @row_count > 0 BEGIN INSERT INTO #results(table_name, records) VALUES ('RiskScore', @row_count) END

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
$log_connection.ConnectionString = "Server=" + $Server + ";Database=QA;User ID=batch;Password=B@7c`$J08s"
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
else
{
    $type_id = 9999
}

$type_reader.Close()

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
