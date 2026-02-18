<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        07/25/2023	DK				Original script
        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This script will delete file data loaded into the Identifi Member database given the filename

    
    .DESCRIPTION

        Given the filename, any data related to an Identifi Member file will be deleted
        from the database
    

    .PARAMETER MemberId

        Specify the file name to be deleted


    .PARAMETER ClientKey

        Specify the client that the file was loaded for (e.g. 10606, 10609)


    .PARAMETER Database

        Specify the database name to connect to (e.g. automation, regression, etc.)


    .PARAMETER UserId

        Specify the user id for connecting to the database


    .PARAMETER Password

        Specify the password for connecting to the database


    .PARAMETER LogId

        Specify the password for connecting to the database

    EXAMPLE
    .\Delete-IMDataMember.ps1 -Server "aldqrdb09" -MemberId "EB-2500%" -ClientKey "10609" -Database "mdsd-auto-001" -UserId "md_readwrite_user" -Password "QcjoFfdtimmKHP4by4HQ" -LogId "100" 


#>

[CmdletBinding()]
Param(

    [Parameter(Mandatory=$True)]
    [string]$Server,

    [Parameter(Mandatory=$True)]
    [string]$MemberId,

    [Parameter(Mandatory=$True)]
    [string]$ClientKey,

    [Parameter(Mandatory=$True)]
    [string]$Database,

    [Parameter(Mandatory=$True)]
    [string]$UserId,

    [Parameter(Mandatory=$True)]
    [string]$Password,

    [Parameter(Mandatory=$True)]
    [int32]$LogId,

    [Parameter(Mandatory=$True)]
    [string]$LogServer
)

$ConnectionString = "Server=tcp:ipe1qa-hpss-001.database.windows.net,1433;Initial Catalog=" + $Database + ";Persist Security Info=False;User ID=" + $UserId + ";Password=" + $Password + ";MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

#**************************************************************************************************
# Set the SQL commands to be executed
#**************************************************************************************************
$sql = "DECLARE @row_count		INT


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

		        DELETE DA
		          FROM dbo.Demographic_Address	DA
		         WHERE DA.Client_Key            = @client_key
                   AND DA.MemberId              LIKE @member_id

		        SELECT @row_count = @@ROWCOUNT
		        IF @row_count > 0 BEGIN INSERT INTO #results(table_name, records) VALUES ('Demographic_Address', @row_count) END

		        DELETE DF
		          FROM dbo.Demographic_FreeformElement	DF
		         WHERE DF.Client_Key                    = @client_key
                   AND DF.MemberId                      LIKE @member_id

		        SELECT @row_count = @@ROWCOUNT
		        IF @row_count > 0 BEGIN INSERT INTO #results(table_name, records) VALUES ('Demographic_FreeformElement', @row_count) END

		        DELETE DM
		          FROM dbo.Demographic_MiscElement		DM
		         WHERE DM.Client_Key                    = @client_key
                   AND DM.MemberId                      LIKE @member_id

		        SELECT @row_count = @@ROWCOUNT
		        IF @row_count > 0 BEGIN INSERT INTO #results(table_name, records) VALUES ('Demographic_MiscElement', @row_count) END


		        DELETE DP
		          FROM dbo.Demographic_Phone		DP
		         WHERE DP.Client_Key                = @client_key
                   AND DP.MemberId                  LIKE @member_id

		        SELECT @row_count = @@ROWCOUNT
		        IF @row_count > 0 BEGIN INSERT INTO #results(table_name, records) VALUES ('Demographic_Phone', @row_count) END

		        DELETE DA
		          FROM dbo.DemographicsAggregated	DA
		         WHERE DA.Client_Key                = @client_key
                   AND DA.MemberId                  LIKE @member_id

		        SELECT @row_count = @@ROWCOUNT
		        IF @row_count > 0 BEGIN INSERT INTO #results(table_name, records) VALUES ('DemographicsAggregated', @row_count) END

		        DELETE DS
		          FROM dbo.Demographic_SyncToAldera	DS
		         WHERE DS.Client_Key                = @client_key
                   AND DS.MemberId                  LIKE @member_id

		        SELECT @row_count = @@ROWCOUNT
		        IF @row_count > 0 BEGIN INSERT INTO #results(table_name, records) VALUES ('Demographic_SyncToAldera', @row_count) END

		        DELETE MA
		          FROM dbo.MemberAttribute	        MA
		         WHERE MA.Client_Key                = @client_key
                   AND MA.MemberId                  LIKE @member_id

		        SELECT @row_count = @@ROWCOUNT
		        IF @row_count > 0 BEGIN INSERT INTO #results(table_name, records) VALUES ('MemberAttribute', @row_count) END

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

    $sql_cmd.Parameters.Add('@member_id', $MemberId) >> $null
    $sql_cmd.Parameters.Add('@client_key', $ClientKey) >> $null

    $sql_reader = $sql_cmd.ExecuteReader()

#**************************************************************************************************
# Log results of the delete
#**************************************************************************************************
    $log_connection = New-Object System.Data.SqlClient.SqlConnection
    $log_connection.ConnectionString = "Server=" + $LogServer + ";Database=QA;Trusted_Connection=True;"
    $log_connection.Open()

    $log_command = New-Object System.Data.SqlClient.SqlCommand
    $log_command.CommandType = [System.Data.CommandType]::StoredProcedure
    $log_command.CommandText = "dbo.spDDAuto_LogEvent"
    $log_command.Connection  = $log_connection

    $parameter_log_id  = $log_command.Parameters.Add("@log_id",       [Data.SQLDBType]::Int)
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

            $parameter_log_id.Value  = $LogId
            $parameter_table.Value   = $table_name
            $parameter_records.Value = $records
            $parameter_status.Value  = $status
            $parameter_err_num.Value = $err_num
            $parameter_err_msg.Value = $err_msg

            $log_command.ExecuteNonQuery() >> $null
        }
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
