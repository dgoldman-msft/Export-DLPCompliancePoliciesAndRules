Function Export-DLPCompliancePoliciesAndRule {
    <#
        .SYNOPSIS
            Export DLP compliance policies and rules

        .DESCRIPTION
            Export DLP compliance policies and rules

        .PARAMETER ExportPath
            Custom export path. Default is c:\Temp\DLP

        .PARAMETER ExportToJson

            Export data to JSON format

        .PARAMETER PolicyName

            Name of the policy and rules to export

        .PARAMETER TenantName
            Tenant Name to connect to

        .PARAMETER Upn
            Username with access to the Security and Compliance center

        .EXAMPLE
            PS C:> Export-DLPCompliancePoliciesAndRules -TenantName tenant.onmicrosoft.com -Upn admin@tenant.onmicrosoft.com

            This will log on to the SCC endpoint as admin@tenant.onmicrosoft.com, export all DLP compliance policies and rules and save them in JSON format to c:\Temp\DLP

        .EXAMPLE
            PS C:> Export-DLPCompliancePoliciesAndRules -TenantName tenant.onmicrosoft.com -Upn admin@tenant.onmicrosoft.com -PolicyName "Test DLP Policy"

            This will log on to the SCC endpoint as admin@tenant.onmicrosoft.com and export the "Test DLP Policy" compliance policy and it's rule and save it to JSON format to c:\Temp\DLP

        .NOTES
            None
    #>

    [cmdletbinding()]
    Param (
        [string]
        $ExportPath = "c:\Temp\DLP\",

        [string[]]
        $PolicyName,

        [Parameter(Mandatory = $True, Position = 0)]
        $TenantName,

        [Parameter(Mandatory = $True, Position = 1)]
        $Upn
    )

    begin {
        Write-Output "Starting"
        $domain = [regex]::Replace($TenantName, "\w+@", "")

        try {
            if (-NOT (Test-Path -Path 'c:\Temp\DLP')) {
                Write-Output "$($ExportPath) not found! Created directory"
                New-Item -Path $ExportPath -ItemType Directory -ErrorAction Stop
            }
            else {
                Write-Output "$($ExportPath) already exists!"
            }
        }
        catch {
            Write-Output "ERROR: $_"
            return
        }
    }

    process {
        try {
            # Connect to the Security and Compliance endpoint
            Write-Output "Connecting to Security and Compliance in tenant: $($domain)"
            Connect-IPPSSession -UserPrincipalName $Upn -ErrorAction Stop

            # Export DLP compliance policies
            if ($PolicyName) {
                Write-Output "Retrieving DLP compliance policy: $($PolicyName)"
                $policiesFound = Get-DLPCompliancePolicy -Identity "$PolicyName" -ErrorAction Stop
            }
            else {
                Write-Output "Retrieving all DLP compliance policies"
                $policiesFound = Get-DLPCompliancePolicy -ErrorAction Stop
            }

            if ($PolicyName) {
                # Export DLP compliance policy rules
                Write-Output "Retrieving DLP compliance policy rules"
                $rulesFound = Get-DlpComplianceRule -Policy "$PolicyName" -ErrorAction Stop
            }
            else {
                # Export DLP compliance policy rules
                Write-Output "Retrieving all DLP compliance policy rules"
                $rulesFound = Get-DlpComplianceRule -ErrorAction Stop
            }

            # Convert and export the policies
            Write-Output "Converting to JSON format and exporting policies to $($ExportPath)"
            $policyJson = $policiesFound | ConvertTo-Json -Depth 10
            $rulesJson = $rulesFound | ConvertTo-Json -Depth 15
            $policyJson | Out-File -FilePath "$($ExportPath)\DLPCompliancePolicies.json" -ErrorAction Stop
            $rulesJson | Out-File -FilePath "$($ExportPath)\DLPCompliancePolicyRules.json" -ErrorAction Stop
        }
        catch {
            Write-Output "ERROR: $_"
            return
        }
    }

    end {
        # Cleanup
        Write-Verbose "Cleaning up remote sessions and disconnecting"
        Get-PSSession | Remove-PSSession
        Write-Output "Finished!`r`nData saved to: $($ExportPath)\DLPCompliancePolicies.json"
    }
}