# Login to Azure
Connect-AzAccount

# Global Variables
$subscriptionId = (Get-AzContext).Subscription.Id
$cloudProjectContributor = Get-AzRoleDefinition -Name 'Cloud Project Contributor'

# Create or modify cloud project custom role
if ($cloudProjectContributor)
{
    $cloudProjectContributor.AssignableScopes.Add("/subscriptions/$subscriptionId")
    Set-AzRoleDefinition -Role $cloudProjectContributor
}
else 
{
    ((Get-Content -Path '.\3 - Cloud Projects\cloud-project-contributor-role-definition-template.json' -Raw) -replace '<subscriptiond-id>', $subscriptionId) | Set-Content -Path '.\3 - Cloud Projects\cloud-project-contributor-role-definition.json' -Force
    New-AzRoleDefinition -InputFile '.\3 - Cloud Projects\cloud-project-contributor-role-definition.json'
    Remove-Item -Path '.\3 - Cloud Projects\cloud-project-contributor-role-definition.json' -Force
}

# Assign individual as custom role to subscription
$subsUserId = (Get-AzADUser -SearchString 'Subscription User 1').Id
New-AzRoleAssignment -ObjectId $subsUserId -Scope "/subscriptions/$subscriptionId" -RoleDefinitionName 'Cloud Project Contributor'