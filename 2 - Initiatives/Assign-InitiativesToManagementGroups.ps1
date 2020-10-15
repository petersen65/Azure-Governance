# Login to Azure
Connect-AzAccount

# Define and assign Policy Sets (initiatives) to Management Groups
$custodianServicesInitiative = New-AzPolicySetDefinition `
    -Name 'custodian-services' -DisplayName 'Custodian Services' -Description 'Initiative for custodian services' `
    -PolicyDefinition '.\2 - Initiatives\custodian-services-initiative.json' `
    -ManagementGroupName 'custodian-services' `
    -Parameter '{ "AllowedLocations": { "type": "array" } }'

$division1ProjectsInitiative = New-AzPolicySetDefinition `
    -Name 'division-1-projects' -DisplayName 'Division 1 Projects' -Description 'Initiative for division 1 projects' `
    -PolicyDefinition '.\2 - Initiatives\division-1-projects-initiative.json' `
    -ManagementGroupName 'division-1-projects' `
    -Parameter '{ "AllowedLocations": { "type": "array" }, "ResourceTypesNotAllowed": { "type": "array" }, "RequiredResourceGroupTagName": { "type": "string" }, "RequiredResourceTagName": { "type": "string" } }'

$division2ProjectsInitiative = New-AzPolicySetDefinition `
    -Name 'division-2-projects' -DisplayName 'Division 2 Projects' -Description 'Initiative for division 2 projects' `
    -PolicyDefinition '.\2 - Initiatives\division-2-projects-initiative.json' `
    -ManagementGroupName 'division-2-projects' `
    -Parameter '{ "AllowedLocations": { "type": "array" }, "ResourceTypesNotAllowed": { "type": "array" }, "RequiredResourceGroupTagName": { "type": "string" }, "RequiredResourceTagName": { "type": "string" } }'

New-AzPolicyAssignment `
    -Name 'custodian-services' -DisplayName 'Custodian Services' -Description 'Initiative for custodian services' `
    -EnforcementMode DoNotEnforce `
    -PolicySetDefinition $custodianServicesInitiative `
    -Scope '/providers/Microsoft.Management/managementgroups/custodian-services' `
    -AllowedLocations @('WestEurope', 'NorthEurope', 'Global', 'GermanyWestCentral', 'GermanyNorth')

New-AzPolicyAssignment `
    -Name 'division-1-projects' -DisplayName 'Division 1 Projects' -Description 'Initiative for division 1 projects' `
    -EnforcementMode Default `
    -PolicySetDefinition $division1ProjectsInitiative `
    -Scope '/providers/Microsoft.Management/managementgroups/division-1-projects' `
    -AllowedLocations @('WestEurope', 'NorthEurope', 'Global') `
    -ResourceTypesNotAllowed @('Microsoft.Network.publicIPAddresses', 'Microsoft.Network.publicIPPrefixes') `
    -RequiredResourceGroupTagName 'businessOwner' -RequiredResourceTagName 'appName'

New-AzPolicyAssignment `
    -Name 'division-2-projects' -DisplayName 'Division 2 Projects' -Description 'Initiative for division 2 projects' `
    -EnforcementMode Default `
    -PolicySetDefinition $division2ProjectsInitiative `
    -Scope '/providers/Microsoft.Management/managementgroups/division-2-projects' `
    -AllowedLocations @('WestEurope', 'NorthEurope', 'Global') `
    -ResourceTypesNotAllowed @('Microsoft.Network.publicIPAddresses', 'Microsoft.Network.publicIPPrefixes') `
    -RequiredResourceGroupTagName 'businessOwner' -RequiredResourceTagName 'appName'