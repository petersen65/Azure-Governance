# Install script from PowerShell Gallery 
# Accept path update and restart PowerShell Core sessions or VS Code
Install-Script -Name Manage-AzureRMBlueprint -Scope CurrentUser

# Login to Azure
Connect-AzAccount

# Import Azure Blueprint into target export directory
Manage-AzureRMBlueprint.ps1 -ModuleMode Az -Mode Export -ExportDir '.\0 - Subscriptions\Blueprint'

# Export Azure Blueprint into target Azure Management Group from source import directory
Manage-AzureRMBlueprint.ps1 -ModuleMode Az -Mode Import -ImportDir '.\0 - Subscriptions\Blueprint\shared-services-blueprint' -NewBlueprintName 'prod-shared-services-blueprint'

# Sample Assignment of an Azure Blueprint
Install-Module -Name Az.Blueprint
Connect-AzAccount
$subsciptionId = (Get-AzContext).Subscription.Id

$blueprintOrganization = "contoso$((Get-Date).DayOfYear)"
$blueprintLocation = 'westeurope'
$keyVaultUserObjectId = (Get-AzADUser -StartsWith 'SST User').Id
$keyVaultJumpboxPassword = 'Pass0wrd!2019#Sample#JB!'
$keyVaultDomainPassword = 'Pass0wrd!2019#Sample#AD!'
$hubVnetResourceId = (Get-AzVirtualNetwork -Name 'westeurope-hub' -ResourceGroupName 'Networking').Id

$blueprint = Get-AzBlueprint | Where-Object -Property Name -Value 'prod-shared-services-blueprint' -EQ
    
$params = `
    @{ 'organization' = $blueprintOrganization; `
       'resource-group-location' = $blueprintLocation; `
       'keyvault_deployment-user-object-id' = $keyVaultUserObjectId; `
       'keyvault_jumpbox-local-admin-user-password' = $keyVaultJumpboxPassword; `
       'keyvault_ad-domain-admin-user-password' = $keyVaultDomainPassword; `
       'hub-vnet-resource-id' = $hubVnetResourceId; `
    }

New-AzBlueprintAssignment -Name "assignment-$($blueprint.Name)" `
                          -Blueprint $blueprint `
                          -SubscriptionId $subsciptionId `
                          -Location $blueprintLocation `
                          -SystemAssignedIdentity `
                          -Lock 'None' `
                          -Parameter $params