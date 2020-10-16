# Login to Azure
Connect-AzAccount

# Remove and unassign Policies and Policy Sets (initiatives) from Management Groups
Remove-AzPolicyAssignment -Name 'division-2-projects' `
    -Scope '/providers/Microsoft.Management/managementgroups/division-2-projects'

Remove-AzPolicyAssignment -Name 'division-1-projects' `
    -Scope '/providers/Microsoft.Management/managementgroups/division-1-projects'

Remove-AzPolicyAssignment -Name 'custodian-services' `
    -Scope '/providers/Microsoft.Management/managementgroups/custodian-services'

Remove-AzPolicySetDefinition -Name 'custodian-services' -ManagementGroupName 'custodian-services' -Force
Remove-AzPolicySetDefinition -Name 'division-2-projects' -ManagementGroupName 'division-2-projects' -Force
Remove-AzPolicySetDefinition -Name 'division-1-projects' -ManagementGroupName 'division-1-projects' -Force

Remove-AzPolicyDefinition -Name 'enforce-image-publishers' -ManagementGroupName 'custodian-services' -Force
Remove-AzPolicyDefinition -Name 'enforce-deny-all-vnet-inbound-on-nsg' -ManagementGroupName 'custodian-services' -Force
Remove-AzPolicyDefinition -Name 'deny-vm-managed-disk-without-cmk' -ManagementGroupName 'custodian-services' -Force
Remove-AzPolicyDefinition -Name 'deny-reserved-names' -ManagementGroupName 'custodian-services' -Force
Remove-AzPolicyDefinition -Name 'audit-nsg-on-nic' -ManagementGroupName 'custodian-services' -Force
Remove-AzPolicyDefinition -Name 'allow-role-definitions-in-iam' -ManagementGroupName 'custodian-services' -Force