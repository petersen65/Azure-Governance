# Login to Azure
Connect-AzAccount

# Global Variables
$subscriptionId = (Get-AzContext).Subscription.Id
$sharedServiceContributor = Get-AzRoleDefinition -Name 'Shared Service Contributor'

# Create or modify shared service custom role
if ($sharedServiceContributor)
{
    $sharedServiceContributor.AssignableScopes.Add("/subscriptions/$subscriptionId")
    Set-AzRoleDefinition -Role $sharedServiceContributor
}
else 
{
    ((Get-Content -Path '.\4 - Shared Services\shared-service-contributor-role-definition-template.json' -Raw) -replace '<subscriptiond-id>', $subscriptionId) | Set-Content -Path '.\4 - Shared Services\shared-service-contributor-role-definition.json' -Force
    New-AzRoleDefinition -InputFile '.\4 - Shared Services\shared-service-contributor-role-definition.json'
    Remove-Item -Path '.\4 - Shared Services\shared-service-contributor-role-definition.json' -Force
}

# Assign individual as custom role to subscription
$subsUserId = (Get-AzADUser -SearchString 'Subscription User 2').Id
New-AzRoleAssignment -ObjectId $subsUserId -Scope "/subscriptions/$subscriptionId" -RoleDefinitionName 'Shared Service Contributor'