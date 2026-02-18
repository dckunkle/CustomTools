<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        01/18/2023	DK				Original script

        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This script imports plan data from the RFF Interest into the API Automation database

    
    .DESCRIPTION

        This script imports plan data from the RFF Interest into the API Automation database
    

    .PARAMETER File

        Specifies the full filename of the RFF Interest that is being imported


    .PARAMETER FileID

        Specifies the file ID of the RFF Interest being imported


#>

[CmdletBinding()]
Param(

    [Parameter(Mandatory)]
    [string]$File,

    [Parameter(Mandatory)]
    [Int16]$FileID
)

begin
{
    $continue = 'Yes'
    $filename = (Get-Item $File).Name

    #**************************************************************************************************
    # Create the log command, to log any File errors
    #**************************************************************************************************
    try
    {   
        
        $api_instance = 'wqadbhpauto01'
        $api_database = 'APIAutomation'
        $api_connection = .\New-SQLConnection.ps1 -instance_name $api_instance -database $api_database

        $log_command = New-Object System.Data.SqlClient.SqlCommand
        $log_command.CommandType = [System.Data.CommandType]'StoredProcedure'
        $log_command.CommandText = "dbo.spAPIAuto_ImportRFFInterestError"
        $log_command.Connection  = $api_connection

        $log_command.Parameters.Add("@iFileID",   [Data.SQLDBType]::Int)           >> $null
        $log_command.Parameters.Add("@iLevel",    [Data.SQLDBType]::VarChar, 100)  >> $null
        $log_command.Parameters.Add("@iRowID",    [Data.SQLDBType]::Int)           >> $null
        $log_command.Parameters.Add("@iColumnID", [Data.SQLDBType]::VarChar, 5)    >> $null
        $log_command.Parameters.Add("@err_num",   [Data.SQLDBType]::Int)           >> $null
        $log_command.Parameters.Add("@err_msg",   [Data.SQLDBType]::VarChar, 8000) >> $null

        #For File level errors, these fields will be the same
        $log_command.Parameters["@iFileID"].Value   = $FileID
        $log_command.Parameters["@iLevel"].Value    = "File"
        $log_command.Parameters["@iRowID"].Value    = 0
        $log_command.Parameters["@iColumnID"].Value = ""

    }
    catch
    {
        Write-Host 'Update State: '$_

        $workbook.Close($false)
        $excel.Quit()

        Exit 1
    }
    #**************************************************************************************************
    # Open the file and verify there is one worksheet and it is a state abbreviation
    #**************************************************************************************************
    try
    {
        $excel = New-Object -comobject Excel.Application
        $workbook = $excel.Workbooks.Open($File)

        #Set the first worksheet active and get the name
        $worksheet = $workbook.Sheets(1)
        $worksheet.Activate()
        $worksheet_name = $worksheet.Name

        #If there is more than one worksheet in the the spreadsheet then exit without processing
        if ($workbook.Worksheets.Count -gt 1)
        {
            $continue = "No"

            #Log the error
            $log_command.Parameters["@err_num"].Value   = "10"
            $log_command.Parameters["@err_msg"].Value   = "The RFF Interest process only allows for spreadsheets with a single worksheet in them."           
            $log_command.ExecuteNonQuery() >> $null
        }

        $states = @("AB","AK","AL","AM","AR","AS","AZ","BC","BV","CA","CO","CT","DC",
                    "DE","FL","GA","GU","HI","IA","ID","IL","IN","KS","KY","LA","MA",
                    "MB","MD","ME","MI","MN","MO","MP","MS","MT","NC","ND","NE","NH",
                    "NJ","NL","NM","NS","NT","NU","NV","NY","OH","OK","ON","OR","PA",
                    "PE","PR","QC","RI","SC","SD","SK","TN","TX","UT","VA","VI","VT",
                    "WA","WI","WV","WY","YT")

        if (!($states.Contains($worksheet_name)))
        {
            $continue = "No"
                        
            #Log the error
            $log_command.Parameters["@err_num"].Value   = "11"
            $log_command.Parameters["@err_msg"].Value   = "The worksheet name is not valid for an RFF Interest file (US state abbreviation)."           
            $log_command.ExecuteNonQuery() >> $null
        }     
                
        $max_column = $worksheet.UsedRange.Columns.Count
        $max_row    = $worksheet.UsedRange.Rows.Count

    }
    catch
    {
        Write-Host 'Open Spreadsheet: '$_
        Exit 1
    }

    #**************************************************************************************************
    # Validate the RFF Interest worksheet headings
    #**************************************************************************************************
    try
    {   
        if($continue -eq "Yes")
        {
            $headings = @([PSCustomObject]@{column='1'  ;column_name='Scenario'}
                          [PSCustomObject]@{column='5'  ;column_name='State'}
                          [PSCustomObject]@{column='6'  ;column_name='Network Status'}
                          [PSCustomObject]@{column='8'  ;column_name='Claim Form Type'}
                          [PSCustomObject]@{column='19' ;column_name='Submitted Amount'}
                          [PSCustomObject]@{column='21' ;column_name='Net Amount'}
                          [PSCustomObject]@{column='25' ;column_name='Run Date'}
                          [PSCustomObject]@{column='29' ;column_name='Member ID'}
                          [PSCustomObject]@{column='30' ;column_name='Claim Number'}
                          [PSCustomObject]@{column='42' ;column_name='Corrected Claim'})

            $err_msg = ''
            $status = ''


            foreach ($heading in $headings)
            {

                $column = [int]$heading.column

                $worksheet_heading = $worksheet.Cells.Item(1,$column).Text
                $expected_heading = [string]$heading.column_name


                if ($worksheet_heading -ne $expected_heading)
                {
                    $continue = "No"
                }
            }

            if ($continue -eq "No")
            {
                #Log the error
                $log_command.Parameters["@err_num"].Value   = "12"
                $log_command.Parameters["@err_msg"].Value   = "The worksheet headings do not match the expected headings for a RFF Interest spreadsheet."           
                $log_command.ExecuteNonQuery() >> $null
            }
        }
    }
    catch
    {
        Write-Host 'Check Headings: '$_

        $workbook.Close($false)
        $excel.Quit()

        Exit 1
    }

    #**************************************************************************************************
    # Update the state now that it is known
    #**************************************************************************************************
    try
    {   
        if ($continue -eq 'Yes')
        {

            $state_command = New-Object System.Data.SqlClient.SqlCommand
            $state_command.CommandType = [System.Data.CommandType]'StoredProcedure'
            $state_command.CommandText = "dbo.spAPIAuto_RFFInterestUpdateState"
            $state_command.Connection  = $api_connection

            $state_command.Parameters.Add("@iFileID", [Data.SQLDBType]::Int) >> $null
            $state_command.Parameters.Add("@iStateSelected", [Data.SQLDBType]::VarChar, 20) >> $null

            $state_command.Parameters["@iFileID"].Value        = $FileID
            $state_command.Parameters["@iStateSelected"].Value = $worksheet_name

            $state_command.ExecuteNonQuery() >> $null
        }

    }
    catch
    {
        Write-Host 'Update State: '$_

        $workbook.Close($false)
        $excel.Quit()

        Exit 1
    }
}
process
{

    #**************************************************************************************************
    # Ouptut the plan details
    #**************************************************************************************************
    try
    {
        if ($continue -eq "Yes")
        {
            Write-Host ""
            Write-Host "     --Processing-Rows----------------------------------------------------------------------------------------------------------------------------"
            Write-Host "     "
            Write-Host "          " -NoNewline

            for (($row = 2); $row -le $max_row; $row++)
            {
        
                $row_string = [string]$row
                Write-Host $row_string.PadLeft(5) -NoNewline

                if ($row % 25 -eq 0) 
                {
                    Write-Host ""
                    Write-Host "     " -NoNewline
                }

                [PSCustomObject]@{
                    FileID                      = $file_id
                    RowID                       = $row
                    StateSelected               = $worksheet_name

                    Scenario                    = $worksheet.Cells.Item($row,1).Text
	                ScenarioType                = $worksheet.Cells.Item($row,2).Text
	                Automate                    = $worksheet.Cells.Item($row,3).Text
	                ScenarioDetail              = $worksheet.Cells.Item($row,4).Text
	                State                       = $worksheet.Cells.Item($row,5).Text
	                NetworkStatus               = $worksheet.Cells.Item($row,6).Text
	                Tier                        = $worksheet.Cells.Item($row,7).Text
	                ClaimFormType               = $worksheet.Cells.Item($row,8).Text
	                SubmissionFormat            = $worksheet.Cells.Item($row,9).Text
	                AdjudicationType            = $worksheet.Cells.Item($row,10).Text
	                PaidRFF1                    = $worksheet.Cells.Item($row,11).Text
	                PaidTimelyRFF1              = $worksheet.Cells.Item($row,12).Text
	                PaidRFF2                    = $worksheet.Cells.Item($row,13).Text
	                PaidTimelyRFF2              = $worksheet.Cells.Item($row,14).Text
	                PaidRFF3                    = $worksheet.Cells.Item($row,15).Text
	                PaidTimelyRFF3              = $worksheet.Cells.Item($row,16).Text
	                PaidRFF4                    = $worksheet.Cells.Item($row,17).Text
	                PaidTimelyRFF4              = $worksheet.Cells.Item($row,18).Text
	                SubmittedAmount             = $worksheet.Cells.Item($row,19).Text
	                TrueAllowedAmount           = $worksheet.Cells.Item($row,20).Text
	                NetAmount                   = $worksheet.Cells.Item($row,21).Text
	                PatientResponsibilityAmount = $worksheet.Cells.Item($row,22).Text
	                ContractDiscount            = $worksheet.Cells.Item($row,23).Text
	                ReceivedDate                = $worksheet.Cells.Item($row,24).Text
	                RunDate                     = $worksheet.Cells.Item($row,25).Text
	                ClaimLineNumber             = $worksheet.Cells.Item($row,26).Text
	                Step                        = $worksheet.Cells.Item($row,27).Text
	                Change                      = $worksheet.Cells.Item($row,28).Text
	                MemberID                    = $worksheet.Cells.Item($row,29).Text
	                ClaimNumber                 = $worksheet.Cells.Item($row,30).Text
	                GroupID                     = $worksheet.Cells.Item($row,31).Text
	                LOB                         = $worksheet.Cells.Item($row,32).Text
	                PatientAccountNumber        = $worksheet.Cells.Item($row,33).Text
	                ProviderID                  = $worksheet.Cells.Item($row,34).Text
	                NPI                         = $worksheet.Cells.Item($row,35).Text
	                ExpectedResultPenaltyDays   = $worksheet.Cells.Item($row,36).Text
	                PenaltyDays                 = $worksheet.Cells.Item($row,37).Text
	                PenaltyAmount               = $worksheet.Cells.Item($row,38).Text
	                ManualInterest              = $worksheet.Cells.Item($row,39).Text
	                Verified                    = $worksheet.Cells.Item($row,40).Text
	                CorrectedClaimRelation      = $worksheet.Cells.Item($row,41).Text
	                CorrectedClaim              = $worksheet.Cells.Item($row,42).Text

                }

            }

            Write-Host ""
            Write-Host ""
            Write-Host ""
        }
    }
    catch
    {
        Write-Host 'Output Rows: '$_
        
        $workbook.Close($false)
        $excel.Quit()

        Exit 1
    }
}
end
{
    $workbook.Close($false)
    $excel.Quit()

    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) >> $null
}