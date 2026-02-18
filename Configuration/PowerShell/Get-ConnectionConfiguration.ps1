<# ***************************************************************************************************
Purpose:      Return the connection string to the configuration database
              Currently hard coding this string. In the future, may get it from a config file  
Parameters: 
    
    None

Date        User            Change
---------------------------------------------------------------------------------------------
01/12/2022	DK				Original script

---------------------------------------------------------------------------------------------

*************************************************************************************************** #>

[CmdLetBinding()]
Param(

)

#**************************************************************************************************
# Setup object to save results in
#**************************************************************************************************
$function_results = [PSCustomObject]@{

    connection_string = "Not Found"
    error_message  = ""
}

$function_results.connection_string = "Server=wqadbhpauto01;Database=Configuration;Trusted_Connection=True;"

$function_results