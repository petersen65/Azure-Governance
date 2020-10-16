Install-Module -Name 'Az' -Scope AllUsers
Install-Module -Name 'Az.Blueprint' -Scope AllUsers
Get-Command -Module 'Az.Blueprint'
Connect-AzAccount -TenantId 'd7221ab3-33ca-4c86-8a48-223fb4b7eec5' -Subscription '44d52a91-614e-4f0a-a321-6f2e24488fc8'

$subscriptionId = (Get-AzContext).Subscription.Id
#$subscriptionId = '44d52a91-614e-4f0a-a321-6f2e24488fc8'   #oneplatform.blueprint-test
$managementGroupId = 'enbw-standard'

Import-AzBlueprintWithArtifact -Name 'enbw-oneplatform-default' -ManagementGroupId $managementGroupId -InputPath '.\Blueprints\enbw-oneplatform-default\'
Import-AzBlueprintWithArtifact -Name 'enbw-oneplatform-network' -ManagementGroupId $managementGroupId -InputPath '.\Blueprints\enbw-oneplatform-network\'
Import-AzBlueprintWithArtifact -Name 'enbw-oneplatform-infra' -ManagementGroupId $managementGroupId -InputPath '.\Blueprints\enbw-oneplatform-infra\'

$default = Get-AzBlueprint -Name 'enbw-oneplatform-default' -ManagementGroupId $managementGroupId
$network = Get-AzBlueprint -Name 'enbw-oneplatform-network' -ManagementGroupId $managementGroupId
$infrastructure = Get-AzBlueprint -Name 'enbw-oneplatform-infra' -ManagementGroupId $managementGroupId

Export-AzBlueprintWithArtifact -Blueprint $default -OutputPath '.\Blueprints\'
Export-AzBlueprintWithArtifact -Blueprint $network -OutputPath '.\Blueprints\'
Export-AzBlueprintWithArtifact -Blueprint $infrastructure -OutputPath '.\Blueprints\'

Publish-AzBlueprint -Blueprint $default -Version '0.5' -ChangeNote 'n/a'
Publish-AzBlueprint -Blueprint $infrastructure -Version '0.5' -ChangeNote 'n/a'
Publish-AzBlueprint -Blueprint $network -Version '0.5' -ChangeNote 'n/a'

$default = Get-AzBlueprint -Name 'enbw-oneplatform-default' -ManagementGroupId $managementGroupId -Version '0.5'
$network = Get-AzBlueprint -Name 'enbw-oneplatform-network' -ManagementGroupId $managementGroupId -Version '0.5'
$infrastructure = Get-AzBlueprint -Name 'enbw-oneplatform-infra' -ManagementGroupId $managementGroupId -Version '0.5'


# enbw-oneplatform-default ########################################################################
$params = `
@{
    'costcenter'             = '1234'; `
        'customerIdentifier' = 'customer-1'; `
        'projectIdentifier'  = 'project-1' `

}

$rgparams = `
@{ ResourceGroup = @{ name = 'oneplatform-default-rg'; location = 'westeurope' } }

New-AzBlueprintAssignment -Name 'assignment-enbw-oneplatform-default' `
    -Blueprint $default `
    -SubscriptionId $subscriptionId `
    -Location 'West Europe' `
    -SystemAssignedIdentity `
    -Lock AllResourcesReadOnly `
    -Parameter $params `
    -ResourceGroupParameter $rgparams

Get-AzBlueprintAssignment -Name 'assignment-enbw-oneplatform-default' -SubscriptionId $subscriptionId
Remove-AzBlueprintAssignment -Name 'assignment-enbw-oneplatform-default' -SubscriptionId $subscriptionId
Remove-AzResourceGroup -Name 'oneplatform-default-rg' -Force


# enbw-oneplatform-network ########################################################################
$params = `
@{
    'oneplatformVirtualNetwork_virtualNetworkName'                = 'oneplatform-vnet'; `
        'oneplatformVirtualNetwork_vnetAddressRange'              = '10.0.128.0/22'; `
        'oneplatformVirtualNetwork_defaultSubnetAddressRange'     = '10.0.128.0/24'; `
        'oneplatformVirtualNetwork_applicationSubnetAddressRange' = '10.0.129.0/24'; `
        'oneplatformVirtualNetwork_databaseSubnetAddressRange'    = '10.0.130.0/24'; `
        'oneplatformVirtualNetwork_privateDnsZoneName'            = 'az.enbw.cloud'; `
        'oneplatformVirtualNetwork_location'                      = 'westeurope' `

}

$rgparams = `
@{ ResourceGroup = @{ name = 'oneplatform-network-rg'; location = 'westeurope' } }

New-AzBlueprintAssignment -Name 'assignment-enbw-oneplatform-network' `
    -Blueprint $network `
    -SubscriptionId $subscriptionId `
    -Location 'West Europe' `
    -SystemAssignedIdentity `
    -Lock AllResourcesReadOnly `
    -Parameter $params `
    -ResourceGroupParameter $rgparams

Get-AzBlueprintAssignment -Name 'assignment-enbw-oneplatform-network' -SubscriptionId $subscriptionId
Remove-AzBlueprintAssignment -Name 'assignment-enbw-oneplatform-network' -SubscriptionId $subscriptionId
Remove-AzResourceGroup -Name 'oneplatform-network-rg' -Force


# enbw-oneplatform-infrastructure #################################################################
$params = `
@{
    'oneplatformLoggingandAutomation_logsPublicDnsName'                = 'oneplatform-logs002'; `
        'oneplatformLoggingandAutomation_automationPublicDnsName'      = 'oneplatform-auto002'; `
        'oneplatformLoggingandAutomation_automationSku'                = 'Basic'; `
        'oneplatformLoggingandAutomation_logsServiceTier'              = 'PerGB2018'; `
        'oneplatformLoggingandAutomation_dataRetention'                = 30; `
        'oneplatformLoggingandAutomation_location'                     = 'westeurope'; `
        'oneplatformStorageAccount_storagePublicDnsName'               = 'oneplatformsa002'; `
        'oneplatformStorageAccount_storageSku'                         = 'Standard_LRS'; `
        'oneplatformStorageAccount_location'                           = 'westeurope'; `
        'oneplatformKeyVault_keyVaultPublicDnsName'                    = 'oneplatform-kv002'; `
        'oneplatformKeyVault_vaultSku'                                 = 'Premium'; `
        'oneplatformKeyVault_location'                                 = 'westeurope'; `
        'oneplatformRecoveryServiceVault_recoveryServicePublicDnsName' = 'oneplatform-backup002'; `
        'oneplatformRecoveryServiceVault_vaultStorageType'             = 'GloballyRedundant'; `
        'oneplatformRecoveryServiceVault_location'                     = 'westeurope' `

}

$rgparams = `
@{ ResourceGroup = @{ name = 'oneplatform-infra-rg'; location = 'westeurope' } }

New-AzBlueprintAssignment -Name 'assignment-enbw-oneplatform-infrastructure' `
    -Blueprint $infrastructure `
    -SubscriptionId $subscriptionId `
    -Location 'West Europe' `
    -SystemAssignedIdentity `
    -Lock AllResourcesDoNotDelete `
    -Parameter $params `
    -ResourceGroupParameter $rgparams

Get-AzBlueprintAssignment -Name 'assignment-enbw-oneplatform-infrastructure' -SubscriptionId $subscriptionId
Remove-AzBlueprintAssignment -Name 'assignment-enbw-oneplatform-infrastructure' -SubscriptionId $subscriptionId

Set-AzBlueprintAssignment -Blueprint $infrastructure `
    -Name 'assignment-enbw-oneplatform-infrastructure' `
    -Lock AllResourcesReadOnly `
    -Location 'West Europe' `
    -Parameter $params `
    -ResourceGroupParameter $rgparams

Remove-AzResourceGroup -Name 'oneplatform-infra-rg' -Force
