# Login to Azure
Connect-AzAccount

# Global Variables
$subscriptionId = (Get-AzContext).Subscription.Id

# Remove cloud project custom role from subscription  
Remove-AzRoleAssignment -ObjectId (Get-AzADUser -SearchString 'Subscription User 2').Id -Scope "/subscriptions/$subscriptionId" -RoleDefinitionName 'Shared Service Contributor'

# Remove custom role definition after it was unassigned from last subscription
Remove-AzRoleDefinition -Name 'Shared Service Contributor' -Force -ErrorAction Ignore