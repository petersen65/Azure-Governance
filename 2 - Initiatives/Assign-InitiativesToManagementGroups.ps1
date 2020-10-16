# Login to Azure
Connect-AzAccount

# Define and assign Policies and Policy Sets (initiatives) to Management Groups
$custodianServicesInitiative = New-AzPolicySetDefinition -Name 'custodian-services' -DisplayName 'Custodian Services' `
    -Description 'Initiative for custodian services' `
    -PolicyDefinition '.\2 - Initiatives\custodian-services-initiative.json' `
    -ManagementGroupName 'custodian-services' `
    -Parameter '{ "AllowedLocations": { "type": "array" } }'

New-AzPolicyDefinition -Name 'allow-role-definitions-in-iam' -DisplayName 'Allow Role Definitions in IAM' `
    -Description 'Define a white list of role definitions that can be used in identity access management' `
    -Mode All `
    -Policy '.\2a - Sample Policy Set\allow-role-definitions-in-iam.json' `
    -ManagementGroupName 'custodian-services' `
    -Parameter ( `
        '{ "RoleDefinition1": { "type": "string" }, ' + `
        '"RoleDefinition2": { "type": "string" }, ' + `
        '"RoleDefinition3": { "type": "string" }, ' + `
        '"RoleDefinition4": { "type": "string" }, ' + `
        '"RoleDefinition5": { "type": "string" } }') `
    -Metadata '{ "category": "Sample" }'
    
New-AzPolicyDefinition -Name 'audit-nsg-on-nic' -DisplayName 'Audit NSG on NIC' `
    -Description 'Audit network interface cards without network security group' `
    -Mode All `
    -Policy '.\2a - Sample Policy Set\audit-nsg-on-nic.json' `
    -ManagementGroupName 'custodian-services' `
    -Metadata '{ "category": "Sample" }'

New-AzPolicyDefinition -Name 'deny-reserved-names' -DisplayName 'Deny reserved names for Azure resources' `
    -Description 'Ensure that a specific set of names cannot be used to create Azure resources' `
    -Mode All `
    -Policy '.\2a - Sample Policy Set\deny-reserved-names.json' `
    -ManagementGroupName 'custodian-services' `
    -Parameter ( `
        '{ "NamePattern": { "type": "string" }, ' + `
        '"BlackList": { "type": "array" } }') `
    -Metadata '{ "category": "Sample" }'

New-AzPolicyDefinition -Name 'deny-vm-managed-disk-without-cmk' -DisplayName 'Deny VM / Managed Disk without CMK' `
    -Description 'Deny when managed disks are not encrypted with CMK via DiskEncryptionSet' `
    -Mode All `
    -Policy '.\2a - Sample Policy Set\deny-vm-managed-disk-without-cmk.json' `
    -ManagementGroupName 'custodian-services' `
    -Metadata '{ "category": "Sample" }'

New-AzPolicyDefinition -Name 'enforce-deny-all-vnet-inbound-on-nsg' -DisplayName 'Enforce DenyAllVnetInBound on NSG' `
    -Description 'Create default security rule DenyAllVnetInBound for all network security groups' `
    -Mode All `
    -Policy '.\2a - Sample Policy Set\enforce-deny-all-vnet-inbound-on-nsg.json' `
    -ManagementGroupName 'custodian-services' `
    -Metadata '{ "category": "Sample" }'

New-AzPolicyDefinition -Name 'enforce-image-publishers' -DisplayName 'Enforce Image Publishers' `
    -Description 'Enforce whitelist for virtual machine image publishers' `
    -Mode All `
    -Policy '.\2a - Sample Policy Set\enforce-image-publishers.json' `
    -ManagementGroupName 'custodian-services' `
    -Parameter '{ "WhiteList": { "type": "array" } }' `
    -Metadata '{ "category": "Sample" }'

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