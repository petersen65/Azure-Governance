# Login to Azure
Connect-AzAccount

# Remove Policy Set (initiative) definitions and assignments from their scopes
Remove-AzPolicyAssignment -Name 'cloud-projects' -Scope '/providers/Microsoft.Management/managementgroups/cloud-projects'
Remove-AzPolicyAssignment -Name 'shared-services' -Scope '/providers/Microsoft.Management/managementgroups/shared-services'
Remove-AzPolicyAssignment -Name 'governance-services' -Scope '/providers/Microsoft.Management/managementgroups/governance-services'

Remove-AzPolicySetDefinition -Name 'cloud-projects' -ManagementGroupName 'cloud-projects' -Force
Remove-AzPolicySetDefinition -Name 'shared-services' -ManagementGroupName 'shared-services' -Force
Remove-AzPolicySetDefinition -Name 'governance-services' -ManagementGroupName 'governance-services' -Force