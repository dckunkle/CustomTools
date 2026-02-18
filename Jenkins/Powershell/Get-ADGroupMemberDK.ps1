Function Get-ADGroupMemberFix {
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string[]]
        $Identity
    )
    process {
        foreach ($GroupIdentity in $Identity) {
            $Group = $null
            $Group = Get-ADGroup -Identity $GroupIdentity -Properties Member
            if (-not $Group) {
                continue
            }
            Foreach ($Member in $Group.Member) {
                Get-ADObject $Member 
            }
        }
    }
}