# Login to Azure
Connect-AzAccount

# Install support for Azure Blueprints
Install-Module -Name 'Az.Blueprint' -Scope AllUsers

# Global variables
$aadTenantId = (Get-AzContext).Tenant.Id
$subscriptionId = (Get-AzContext).Subscription.Id
$location = 'westeurope'

# Deploy diagnostics settings blueprint to management group
Import-AzBlueprintWithArtifact -Name 'diagnostics-settings' `
    -ManagementGroupId $aadTenantId `
    -InputPath '.\3 - Blueprints\diagnostics-settings\' -Force

$bpDefinition = Get-AzBlueprint -ManagementGroupId $aadTenantId -Name 'diagnostics-settings'
Publish-AzBlueprint -Blueprint $bpDefinition -Version '1.0' -ChangeNote 'Diagnostics Settings for subscription activity logs'

$storageAccountId = (Get-AzResource -Name 'petersen' -ResourceGroupName 'Storage').ResourceId
$workspaceIdId = (Get-AzResource -Name 'petersen' -ResourceGroupName 'Monitoring').ResourceId
$userAssignedIdentity = (Get-AzResource -Name 'blueprints-global-owner' -ResourceGroupName 'Security').ResourceId

$params = @{ `
        'diagnosticsSettings_settingName'      = 'Activity Logs Diagnostics'; `
        'diagnosticsSettings_storageAccountId' = $storageAccountId; `
        'diagnosticsSettings_workspaceId'      = $workspaceIdId; 
}

New-AzBlueprintAssignment -Name "assignment-$($bpDefinition.Name)" `
    -Blueprint $bpDefinition `
    -SubscriptionId $subscriptionId `
    -Location $location `
    -UserAssignedIdentity $userAssignedIdentity `
    -Lock 'AllResourcesReadOnly' `
    -Parameter $params