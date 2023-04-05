# Export-DLPCompliancePoliciesAndRules
Export DLP compliance policies and rules

- EXAMPLE 1: Export-DLPCompliancePoliciesAndRules -TenantName tenant.onmicrosoft.com -Upn admin@tenant.onmicrosoft.com

	 This will log on to the SCC endpoint as admin@tenant.onmicrosoft.com, export all DLP compliance policies and rules and save them in JSON format to c:\Temp\DLP

- .EXAMPLE 2: Export-DLPCompliancePoliciesAndRules -TenantName tenant.onmicrosoft.com -Upn admin@tenant.onmicrosoft.com -PolicyName "Test DLP Policy"

	 This will log on to the SCC endpoint as admin@tenant.onmicrosoft.com and export the "Test DLP Policy" compliance policy and it's rule and save it to JSON format to c:\Temp\DLP
