# Login to Azure
Connect-AzAccount

# Global Variables
$tenantId = (Get-AzContext).Tenant.Id
$parentId = "/providers/Microsoft.Management/managementGroups/$tenantId"
$domain = Read-Host -Prompt 'Enter Azure AD Domain Name: '

# Create first level of Management Groups
New-AzManagementGroup -GroupName 'custodian-services' -DisplayName 'Custodian Services' -ParentId $parentId
$division1 = New-AzManagementGroup -GroupName "division-1-projects" -DisplayName "Division 1 Projects" -ParentId $parentId
$division2 = New-AzManagementGroup -GroupName "division-2-projects" -DisplayName "Division 2 Projects" -ParentId $parentId

# Create project level Management Groups (group names must be unique)
New-AzManagementGroup -GroupName "prod-project-x" -DisplayName "PROD Project X" -ParentId $division1
New-AzManagementGroup -GroupName "uat-project-x" -DisplayName "UAT Project X" -ParentId $division1
New-AzManagementGroup -GroupName "prod-project-y" -DisplayName "PROD Project Y" -ParentId $division2
New-AzManagementGroup -GroupName "uat-project-y" -DisplayName "UAT Project Y" -ParentId $division2

# Remove automatically created Owner role assignments on Management Groups
$ownerId = (Get-AzADUser -UserPrincipalName (Get-AzContext).Account.Id).Id
Remove-AzRoleAssignment -ObjectId $ownerId -Scope '/providers/Microsoft.Management/managementgroups/custodian-services' -RoleDefinitionName 'Owner'
Remove-AzRoleAssignment -ObjectId $ownerId -Scope '/providers/Microsoft.Management/managementgroups/division-1-projects' -RoleDefinitionName 'Owner'
Remove-AzRoleAssignment -ObjectId $ownerId -Scope '/providers/Microsoft.Management/managementgroups/division-2-projects' -RoleDefinitionName 'Owner'

Remove-AzRoleAssignment -ObjectId $ownerId -Scope "/providers/Microsoft.Management/managementgroups/prod-project-x" -RoleDefinitionName 'Owner'
Remove-AzRoleAssignment -ObjectId $ownerId -Scope "/providers/Microsoft.Management/managementgroups/uat-project-x" -RoleDefinitionName 'Owner'
Remove-AzRoleAssignment -ObjectId $ownerId -Scope "/providers/Microsoft.Management/managementgroups/prod-project-y" -RoleDefinitionName 'Owner'
Remove-AzRoleAssignment -ObjectId $ownerId -Scope "/providers/Microsoft.Management/managementgroups/uat-project-y" -RoleDefinitionName 'Owner'

# Create custodian team identities
New-AzADGroup -DisplayName 'Custodian Team' -MailNickName 'CT'
New-AzADUser -DisplayName 'CT User' -UserPrincipalName "ctuser@$domain" -Password (ConvertTo-SecureString 'Passw0rd!#' -AsPlainText -Force) -MailNickname 'CTU'
Add-AzADGroupMember -MemberObjectId (Get-AzADUser -SearchString 'CT User').Id -TargetGroupObjectId (Get-AzADGroup -SearchString 'Custodian Team').Id

# Create team identities for division 1 projects
New-AzADGroup -DisplayName 'Division 1 Team' -MailNickName 'D1T'
New-AzADUser -DisplayName 'D1T User' -UserPrincipalName "d1tuser@$domain" -Password (ConvertTo-SecureString 'Passw0rd!#' -AsPlainText -Force) -MailNickname 'D1TU'
Add-AzADGroupMember -MemberObjectId (Get-AzADUser -SearchString 'D1T User').Id -TargetGroupObjectId (Get-AzADGroup -SearchString 'Division 1 Team').Id

# Create team identities for project X
New-AzADGroup -DisplayName 'PROD Project X Team' -MailNickName 'PPXT'
New-AzADGroup -DisplayName 'UAT Project X Team' -MailNickName 'UPXT'

# Create team identities for division 2 projects
New-AzADGroup -DisplayName 'Division 2 Team' -MailNickName 'D2T'
New-AzADUser -DisplayName 'D2T User' -UserPrincipalName "d2tuser@$domain" -Password (ConvertTo-SecureString 'Passw0rd!#' -AsPlainText -Force) -MailNickname 'D2TU'
Add-AzADGroupMember -MemberObjectId (Get-AzADUser -SearchString 'D2T User').Id -TargetGroupObjectId (Get-AzADGroup -SearchString 'Division 2 Team').Id

# Create team identities for project Y
New-AzADGroup -DisplayName 'PROD Project Y Team' -MailNickName 'PPYT'
New-AzADGroup -DisplayName 'UAT Project Y Team' -MailNickName 'UPYT'

# Assign custodian team as Owner to Root Management Group
$custodianTeamId = (Get-AzADGroup -SearchString 'Custodian Team').Id
New-AzRoleAssignment -ObjectId $custodianTeamId -Scope "/providers/Microsoft.Management/managementgroups/$parentId" -RoleDefinitionName 'Owner'

# Assign team identities of division 1 projects as Contributor to their Management Group
$division1TeamId = (Get-AzADGroup -SearchString 'Division 1 Team').Id
New-AzRoleAssignment -ObjectId $division1TeamId -Scope '/providers/Microsoft.Management/managementgroups/division-1-projects' -RoleDefinitionName 'Contributor'

# Assign team identities of division 2 projects as Contributor to their Management Group
$division2TeamId = (Get-AzADGroup -SearchString 'Division 2 Team').Id
New-AzRoleAssignment -ObjectId $division2TeamId -Scope '/providers/Microsoft.Management/managementgroups/division-2-projects' -RoleDefinitionName 'Contributor'

# Assign project X team identities as Contributor to their Management Group
$prodProjectXTeamId = (Get-AzADGroup -SearchString 'PROD Project X Team').Id
$uatProjectXTeamId = (Get-AzADGroup -SearchString 'UAT Project X Team').Id
New-AzRoleAssignment -ObjectId $prodProjectXTeamId -Scope '/providers/Microsoft.Management/managementgroups/prod-project-x' -RoleDefinitionName 'Contributor'
New-AzRoleAssignment -ObjectId $uatProjectXTeamId -Scope '/providers/Microsoft.Management/managementgroups/uat-project-x' -RoleDefinitionName 'Contributor'

# Assign project Y team identities as Contributor to their Management Group
$prodProjectYTeamId = (Get-AzADGroup -SearchString 'PROD Project Y Team').Id
$uatProjectYTeamId = (Get-AzADGroup -SearchString 'UAT Project Y Team').Id
New-AzRoleAssignment -ObjectId $prodProjectYTeamId -Scope '/providers/Microsoft.Management/managementgroups/prod-project-y' -RoleDefinitionName 'Contributor'
New-AzRoleAssignment -ObjectId $uatProjectYTeamId -Scope '/providers/Microsoft.Management/managementgroups/uat-project-y' -RoleDefinitionName 'Contributor'