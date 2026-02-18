<#
    .NOTES
        ---------------------------------------------------------------------------------------------
        Date        User            Change
        ---------------------------------------------------------------------------------------------
        01/18/2023	DK				Original script

        ---------------------------------------------------------------------------------------------

    .SYNOPSIS

        This script saves the plan data, that was selected, from the Benefit Grid

    
    .DESCRIPTION

        This script saves the plan data, that was selected, from the Benefit Grid
    

    .PARAMETER FileID

        Specifies the file name for the Benefit Grid to get plans from


    .PARAMETER SheetID

        Specifies the file name for the Benefit Grid to get plans from


    .PARAMETER Row

        Specifies the file name for the Benefit Grid to get plans from
#>

[CmdletBinding()]
Param(

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [Int16]$FileID,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [Int16]$RowID,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [string]$StateSelected,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$Scenario,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$ScenarioType,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$Automate,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$ScenarioDetail,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$State,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$NetworkStatus,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$Tier,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$ClaimFormType,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$SubmissionFormat,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$AdjudicationType,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$PaidRFF1,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$PaidTimelyRFF1,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$PaidRFF2,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$PaidTimelyRFF2,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$PaidRFF3,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$PaidTimelyRFF3,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$PaidRFF4,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$PaidTimelyRFF4,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$SubmittedAmount,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$TrueAllowedAmount,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$NetAmount,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$PatientResponsibilityAmount,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$ContractDiscount,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$ReceivedDate,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$RunDate,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$ClaimLineNumber,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$Step,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$Change,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$MemberID,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$ClaimNumber,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$GroupID,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$LOB,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$PatientAccountNumber,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$ProviderID,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$NPI,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$ExpectedResultPenaltyDays,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$PenaltyDays,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$PenaltyAmount,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$ManualInterest,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$Verified,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$CorrectedClaimRelation,

    [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
    [AllowEmptyString()]
    [string]$CorrectedClaim

)

begin
{
    #**************************************************************************************************
    # Create connection object to the Configuration database
    #**************************************************************************************************
    try
    {
        $config_instance = 'wqadbhpauto01'
        $config_database = 'APIAutomation'
        $config_connection = .\New-SQLConnection.ps1 -instance_name $config_instance -database $config_database

        $sql_command = New-Object System.Data.SqlClient.SqlCommand
        $sql_command.CommandType = [System.Data.CommandType]'StoredProcedure'
        $sql_command.CommandText = "dbo.spAPIAuto_ImportRFFInterestRecord"
        $sql_command.Connection  = $config_connection

        $sql_command.Parameters.Add("@iFileID",                      [Data.SQLDBType]::Int)           >> $null
        $sql_command.Parameters.Add("@iRowID",                       [Data.SQLDBType]::Int)           >> $null
        $sql_command.Parameters.Add("@iStateSelected",               [Data.SQLDBType]::VarChar, 20)   >> $null

        $sql_command.Parameters.Add("@iScenario",                    [Data.SQLDBType]::VarChar, 1000) >> $null
        $sql_command.Parameters.Add("@iScenarioType",                [Data.SQLDBType]::VarChar, 1000) >> $null
        $sql_command.Parameters.Add("@iAutomate",                    [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iScenarioDetail",              [Data.SQLDBType]::VarChar, 4000) >> $null
        $sql_command.Parameters.Add("@iState",                       [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iNetworkStatus",               [Data.SQLDBType]::VarChar, 50)   >> $null
        $sql_command.Parameters.Add("@iTier",                        [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iClaimFormType",               [Data.SQLDBType]::VarChar, 50)   >> $null
        $sql_command.Parameters.Add("@i837SubmissionFormat",         [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iAdjudicationType",            [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iPaidRFF1",                    [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iPaidTimelyRFF1",              [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iPaidRFF2",                    [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iPaidTimelyRFF2",              [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iPaidRFF3",                    [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iPaidTimelyRFF3",              [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iPaidRFF4",                    [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iPaidTimelyRFF4",              [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iSubmittedAmount",             [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iTrueAllowedAmount",           [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iNetAmount",                   [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iPatientResponsibilityAmount", [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iContractDiscount",            [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iReceivedDate",                [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iRunDate",                     [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iClaimLineNumber",             [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iStep",                        [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iChange",                      [Data.SQLDBType]::VarChar, 4000) >> $null
        $sql_command.Parameters.Add("@iMemberID",                    [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iClaimNumber",                 [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iGroupID",                     [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iLOB",                         [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iPatientAccountNumber",        [Data.SQLDBType]::VarChar, 50)   >> $null
        $sql_command.Parameters.Add("@iProviderID",                  [Data.SQLDBType]::VarChar, 50)   >> $null
        $sql_command.Parameters.Add("@iNPI",                         [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iExpectedResultPenaltyDays",   [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iPenaltyDays",                 [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iPenaltyAmount",               [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iManualInterest",              [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iVerified",                    [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iCorrectedClaimRelation",      [Data.SQLDBType]::VarChar, 20)   >> $null
        $sql_command.Parameters.Add("@iCorrectedClaim",              [Data.SQLDBType]::VarChar, 20)   >> $null


    }
    catch
    {
        Write-Host $_
        Exit 1
    }
}

process
{
    #**************************************************************************************************
    # Save each plan to the Configuration database
    #**************************************************************************************************
    try
    {
        if ($status -eq ""){ $status = "Processed" }

        $sql_command.Parameters["@iFileID"].Value                      = $FileID
        $sql_command.Parameters["@iRowID"].Value                       = $RowID
        $sql_command.Parameters["@iStateSelected"].Value               = $StateSelected
        
        $sql_command.Parameters["@iScenario"].Value                    = $Scenario
        $sql_command.Parameters["@iScenarioType"].Value                = $ScenarioType
        $sql_command.Parameters["@iAutomate"].Value                    = $Automate
        $sql_command.Parameters["@iScenarioDetail"].Value              = $ScenarioDetail
        $sql_command.Parameters["@iState"].Value                       = $State
        $sql_command.Parameters["@iNetworkStatus"].Value               = $NetworkStatus
        $sql_command.Parameters["@iTier"].Value                        = $Tier
        $sql_command.Parameters["@iClaimFormType"].Value               = $ClaimFormType
        $sql_command.Parameters["@i837SubmissionFormat"].Value         = $SubmissionFormat
        $sql_command.Parameters["@iAdjudicationType"].Value            = $AdjudicationType
        $sql_command.Parameters["@iPaidRFF1"].Value                    = $PaidRFF1
        $sql_command.Parameters["@iPaidTimelyRFF1"].Value              = $PaidTimelyRFF1
        $sql_command.Parameters["@iPaidRFF2"].Value                    = $PaidRFF2
        $sql_command.Parameters["@iPaidTimelyRFF2"].Value              = $PaidTimelyRFF2
        $sql_command.Parameters["@iPaidRFF3"].Value                    = $PaidRFF3
        $sql_command.Parameters["@iPaidTimelyRFF3"].Value              = $PaidTimelyRFF3
        $sql_command.Parameters["@iPaidRFF4"].Value                    = $PaidRFF4
        $sql_command.Parameters["@iPaidTimelyRFF4"].Value              = $PaidTimelyRFF4
        $sql_command.Parameters["@iSubmittedAmount"].Value             = $SubmittedAmount
        $sql_command.Parameters["@iTrueAllowedAmount"].Value           = [string]$TrueAllowedAmount
        $sql_command.Parameters["@iNetAmount"].Value                   = $NetAmount
        $sql_command.Parameters["@iPatientResponsibilityAmount"].Value = $PatientResponsibilityAmount
        $sql_command.Parameters["@iContractDiscount"].Value            = $ContractDiscount
        $sql_command.Parameters["@iReceivedDate"].Value                = $ReceivedDate
        $sql_command.Parameters["@iRunDate"].Value                     = $RunDate
        $sql_command.Parameters["@iClaimLineNumber"].Value             = $ClaimLineNumber
        $sql_command.Parameters["@iStep"].Value                        = $Step
        $sql_command.Parameters["@iChange"].Value                      = $Change
        $sql_command.Parameters["@iMemberID"].Value                    = $MemberID
        $sql_command.Parameters["@iClaimNumber"].Value                 = $ClaimNumber
        $sql_command.Parameters["@iGroupID"].Value                     = $GroupID
        $sql_command.Parameters["@iLOB"].Value                         = $LOB
        $sql_command.Parameters["@iPatientAccountNumber"].Value        = $PatientAccountNumber
        $sql_command.Parameters["@iProviderID"].Value                  = $ProviderID
        $sql_command.Parameters["@iNPI"].Value                         = $NPI
        $sql_command.Parameters["@iExpectedResultPenaltyDays"].Value   = $ExpectedResultPenaltyDays
        $sql_command.Parameters["@iPenaltyDays"].Value                 = $PenaltyDays
        $sql_command.Parameters["@iPenaltyAmount"].Value               = $PenaltyAmount
        $sql_command.Parameters["@iManualInterest"].Value              = $ManualInterest
        $sql_command.Parameters["@iVerified"].Value                    = $Verified
        $sql_command.Parameters["@iCorrectedClaimRelation"].Value      = $CorrectedClaimRelation
        $sql_command.Parameters["@iCorrectedClaim"].Value              = $CorrectedClaim

        $sql_command.ExecuteNonQuery() >> $null

    }
    catch
    {
        Write-Host $_
        #Exit 1
    }
}

end
{
    $sql_command.Dispose()
    $config_connection.Close()
}