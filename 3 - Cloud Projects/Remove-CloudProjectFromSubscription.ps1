# Login to Azure
Connect-AzAccount

# Global Variables
$subscriptionId = (Get-AzContext).Subscription.Id

# Remove cloud project custom role from subscription  
Remove-AzRoleAssignment -ObjectId (Get-AzADUser -SearchString 'Subscription User 1').Id -Scope "/subscriptions/$subscriptionId" -RoleDefinitionName 'Cloud Project Contributor'

# Remove custom role definition after it was unassigned from last subscription
Remove-AzRoleDefinition -Name 'Cloud Project Contributor' -Force -ErrorAction Ignore