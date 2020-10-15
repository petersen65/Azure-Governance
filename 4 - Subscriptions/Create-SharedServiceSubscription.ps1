# How to call the API from PowerShell
# $body = `
#     @{ DisplayName = "Shared Service 4"; `
#        ParentManagementGroup = "shared-services"; `
#        NewManagementGroup = "shared-service-4"; `
#        EnrollmentAccountId = "747ddfe5-xxxx-xxxx-xxxx-xxxxxxxxxxxx"; `
#        OwnerId = "xx1792d2-xxxx-xxxx-xxxx-fe9e5d50xxxx"; `
#        BlueprintOrganization = "org"; `
#        BlueprintLocation = "westeurope"; `
#        KeyVaultUserObjectId = "xx4279d2-xxxx-xxxx-xxxx-fe8e5d50xxxx"; `
#        KeyVaultJumpboxPassword = "Pass0wrd!2019#Sample#JB!"; `
#        KeyVaultDomainPassword = "Pass0wrd!2019#Sample#DA!"; `
#        HubVnetResourceId = "/subscriptions/{subscriptionId}/resourceGroups/{resourceGroup}/providers/Microsoft.Network/virtualNetworks/{vnetName}"; `
#     }
# $webHook = 'https://s2events.azure-automation.net/webhooks?token=xy...'
# $requestBody = ConvertTo-Json -InputObject $body
# $responseBody = Invoke-WebRequest -Method Post -Uri $webHook -Body $requestBody
# $jobid = (ConvertFrom-Json ($responseBody.Content)).jobids[0]

# Required permissions for an Azure AD Service Principal running this script
# 1. Account Owner of enrollment account under which the new subscription will be created
# 2. Owner of root management group where a new management group will be created some levels down, that is used as parent for the new subscription in step 1
# 3. Owner of newly created subscription (automatically fulfilled because of inheritance rules down from root management group)
# 4. Network Contributor role assigned on both sides of hub and spoke virtual networks so that peerings can be created between them (assuming 1 AAD tenant for all subscriptions)

param
(
    [Parameter (Mandatory = $false)]
    [object] $WebhookData
)

# If runbook was called from Webhook, WebhookData will not be null.
if ($WebhookData) 
{
    # Extract parameters from JSON payload into PowerShell objects
    $body = (ConvertFrom-Json -InputObject $WebhookData.RequestBody)
    $displayName = $body.DisplayName
    $parentManagementGroup = $body.ParentManagementGroup
    $newManagementGroup = $body.NewManagementGroup
    $enrollmentAccountId = $body.EnrollmentAccountId
    $ownerId = $body.OwnerId
    $blueprintOrganization = $body.BlueprintOrganization
    $blueprintLocation = $body.BlueprintLocation
    $keyVaultUserObjectId = $body.KeyVaultUserObjectId
    $keyVaultJumpboxPassword = $body.KeyVaultJumpboxPassword
    $keyVaultDomainPassword = $body.KeyVaultDomainPassword
    $hubVnetResourceId = $body.HubVnetResourceId

    # Connect to existing Azure Subscription
    $spConn = Get-AutomationConnection -Name 'AzureRunAsConnection'
    Connect-AzAccount -ServicePrincipal -TenantId $spConn.TenantId -ApplicationId $spConn.ApplicationId -CertificateThumbprint $spConn.CertificateThumbprint 

    # Extract first enrollment account id if impersonated service principle is account owner of an Azure Enrollment Account 
    if (!$enrollmentAccountId)
    {
        $enrollmentAccountId = (Get-AzEnrollmentAccount)[0].ObjectId
    }

    # Output for diagnostic purposes
    Write-Output -InputObject $displayName
    Write-Output -InputObject $parentManagementGroup
    Write-Output -InputObject $newManagementGroup
    Write-Output -InputObject $ownerId
    Write-Output -InputObject $enrollmentAccountId
    Write-Output -InputObject $blueprintOrganization
    Write-Output -InputObject $blueprintLocation
    Write-Output -InputObject $keyVaultUserObjectId
    Write-Output -InputObject $hubVnetResourceId

    # Create EA Production Subscription
    New-AzSubscription -OfferType 'MS-AZR-0017P' -Name $displayName -EnrollmentAccountObjectId $enrollmentAccountId -OwnerObjectId $ownerId
    $subscriptionId = (Get-AzSubscription -SubscriptionName $displayName).Id

    # Assign Subscription to new Management Group 
    New-AzManagementGroup -GroupName $newManagementGroup -DisplayName $displayName -ParentId (Get-AzManagementGroup -GroupName $parentManagementGroup).Id 
    New-AzManagementGroupSubscription -GroupName $newManagementGroup -SubscriptionId $subscriptionId

    # Assign Azure Blueprint definition to newly created subscription (shared services example)
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
}
else 
{
    # Error
    Write-Error "This runbook is meant to be started from an Azure alert webhook only."
}