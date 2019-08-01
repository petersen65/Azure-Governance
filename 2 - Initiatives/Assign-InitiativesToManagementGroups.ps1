# Login to Azure
Connect-AzAccount

# Define and assign Policy Set (initiative) to Management Groups
$cloudProjectsInitiative = New-AzPolicySetDefinition -Name 'cloud-projects' -DisplayName 'Cloud Project' -Description 'Initiative for cloud projects' -PolicyDefinition '.\2 - Initiatives\cloud-projects-initiative.json' -ManagementGroupName 'cloud-projects' -Parameter '{ "AllowedLocations": { "type": "array" } }'
$sharedServicesInitiative = New-AzPolicySetDefinition -Name 'shared-services' -DisplayName 'Shared Services' -Description 'Initiative for shared services' -PolicyDefinition '.\2 - Initiatives\shared-services-initiative.json' -ManagementGroupName 'shared-services' -Parameter '{ "AllowedLocations": { "type": "array" } }'
$governanceServicesInitiative = New-AzPolicySetDefinition -Name 'governance-services' -DisplayName 'Governance Services' -Description 'Initiative for governance services' -PolicyDefinition '.\2 - Initiatives\governance-services-initiative.json' -ManagementGroupName 'governance-services' -Parameter '{ "AllowedLocations": { "type": "array" } }'

New-AzPolicyAssignment -Name 'cloud-projects' -DisplayName 'Cloud Project' -Description 'Initiative for cloud projects' -PolicySetDefinition $cloudProjectsInitiative -AllowedLocations '["WestEurope", "NorthEurope"]' -Scope '/providers/Microsoft.Management/managementgroups/cloud-projects'
New-AzPolicyAssignment -Name 'shared-services' -DisplayName 'Shared Services' -Description 'Initiative for shared services' -PolicySetDefinition $sharedServicesInitiative -AllowedLocations '["WestEurope", "NorthEurope"]' -Scope '/providers/Microsoft.Management/managementgroups/shared-services'
New-AzPolicyAssignment -Name 'governance-services' -DisplayName 'Governance Services' -Description 'Initiative for governance services' -PolicySetDefinition $governanceServicesInitiative -AllowedLocations '["WestEurope", "NorthEurope"]' -Scope '/providers/Microsoft.Management/managementgroups/governance-services'