# Login to Azure
Connect-AzAccount

# Remove project level Management Groups
Remove-AzManagementGroup -GroupId 'uat-project-y'
Remove-AzManagementGroup -GroupId 'prod-project-y'
Remove-AzManagementGroup -GroupId 'uat-project-x'
Remove-AzManagementGroup -GroupId 'prod-project-x'

# Remove first level Management Groups
Remove-AzManagementGroup -GroupId 'division-2-projects'
Remove-AzManagementGroup -GroupId 'division-1-projects'
Remove-AzManagementGroup -GroupId 'custodian-services'

# Remove team identities for project Y
Remove-AzADGroup -ObjectId (Get-AzADGroup -SearchString 'UAT Project Y Team').Id -PassThru -Force
Remove-AzADGroup -ObjectId (Get-AzADGroup -SearchString 'PROD Project Y Team').Id -PassThru -Force

# Remove team identities for project X
Remove-AzADGroup -ObjectId (Get-AzADGroup -SearchString 'UAT Project X Team').Id -PassThru -Force
Remove-AzADGroup -ObjectId (Get-AzADGroup -SearchString 'PROD Project X Team').Id -PassThru -Force

# Remove team identities for division 2 projects
Get-AzADUser -SearchString 'D2T User' | Remove-AzADUser -Force
Remove-AzADGroup -ObjectId (Get-AzADGroup -SearchString 'Division 2 Team').Id -PassThru -Force

# Remove team identities for division 1 projects
Get-AzADUser -SearchString 'D1T User' | Remove-AzADUser -Force
Remove-AzADGroup -ObjectId (Get-AzADGroup -SearchString 'Division 1 Team').Id -PassThru -Force

# Remove custodian team identities
Get-AzADUser -SearchString 'CT User' | Remove-AzADUser -Force
Remove-AzUserAssignedIdentity -ResourceGroupName 'Security' -Name 'blueprints-global-owner' -Force
Remove-AzADGroup -ObjectId (Get-AzADGroup -SearchString 'Custodian Team').Id -PassThru -Force