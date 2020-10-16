# Login to Azure
Connect-AzAccount

# Global variables
$aadTenantId = (Get-AzContext).Tenant.Id
$subscriptionId = (Get-AzContext).Subscription.Id

# Remove diagnostics settings blueprint from the management group and unassign it from the subscription
$bpDefinition = Get-AzBlueprint -ManagementGroupId $aadTenantId -Name 'diagnostics-settings'
Remove-AzBlueprintAssignment -Name "assignment-$($bpDefinition.Name)" -SubscriptionId $subscriptionId
Invoke-AzRestMethod -Path "$($bpDefinition.Id)?api-version=2018-11-01-preview" -Method DELETE

# Remove diagnostics settings of Activity Logs on subscription scope
Remove-AzDiagnosticSetting -ResourceId "/subscriptions/$subscriptionId" -Name 'Activity Logs Diagnostics'