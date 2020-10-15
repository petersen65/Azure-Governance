# Azure-Governance
Azure governance project with specific description and scripts how to onboard to the Azure Cloud

# Notes

# Deploy diagnostic settings to subscription
New-AzDeployment -Location 'westeurope' `
    -TemplateFile '.\3 - Blueprints\azuredeploy.diagnostics.json' `
    -TemplateParameterFile '.\3 - Blueprints\azuredeploy.diagnostics.parameters.json'

# Export existing blueprint for diagnostics settings
$bpDefinition = Get-AzBlueprint -ManagementGroupId $aadTenantId -Name 'diagnostic-settings' -Version '1.0'
Export-AzBlueprintWithArtifact -Blueprint $bpDefinition -OutputPath '.\3 - Blueprints\'