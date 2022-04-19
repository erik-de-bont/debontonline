# Example file from www.debontonline.com
# Setup Microsoft 365 environment https://developer.microsoft.com/en-us/microsoft-365/dev-program
# Microsoft graph api documentation: https://docs.microsoft.com/en-us/graph/api/overview?view=graph-rest-1.0&preserve-view=true


# Minimum Required API permission for execution to create a new users
# Group.Create
# Group.ReadWrite.All
# GroupMember.ReadWrite.All
# Directory.ReadWrite.All
# To modify members from a role-assignable group, the calling user or app must also be assigned the "RoleManagement.ReadWrite.Directory" permission.

# Required Powershell Module for certificate authorisation
# Install-Module MSAL.PS 


# Connection information for Graph API connection - Certificate Based
$clientID = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx" #  App Id MS Graph API Connector SPN
$TenantName = "<<tenantname>>.onmicrosoft.com" # Example debontonlinedev.onmicrosoft.com
$TenantID = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx" # Tenant ID 
$CertificatePath = "Cert:\LocalMachine\my\xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # Add the Certificate Path Including Thumbprint here e.g. cert:\currentuser\my\6C1EE1A11F57F2495B57A567211220E0ADD72DC1 >#
##Import Certificate
$Certificate = Get-Item $certificatePath
##Request Token
$TokenResponse = Get-MsalToken -ClientId $ClientId -TenantId $TenantId -ClientCertificate $Certificate
$TokenAccess = $TokenResponse.accesstoken


# Example 1: Create Single Security Group
$CreateSecurityGroupBody = @{
	Description = "Marketing Group"
	DisplayName = "Marketing"
	GroupTypes = @(
	)
	MailEnabled = $false
	MailNickname = "marketing"
	SecurityEnabled = $true
	"Owners@odata.bind" = @(
		"https://graph.microsoft.com/v1.0/users/xxxxx@xxxxx.xxx"
	)
	"Members@odata.bind" = @(
		"https://graph.microsoft.com/v1.0/users/xxxxx@xxxxx.xxx"
		"https://graph.microsoft.com/v1.0/users/xxxxx@xxxxx.xxx"
	)
}

$CreateSecurityGroupUrl = "https://graph.microsoft.com/v1.0/groups"
$CreateSecurityGroup = Invoke-RestMethod -Uri $CreateGroupUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method Post -Body $($CreateSecurityGroupBody | convertto-json) -ContentType "application/json"


# Example 2: Add Members Security Group
## Retrieving the id of the 'Marketing" group
$GroupMailNickName = 'Marketing'
$GetGroupUrl = "https://graph.microsoft.com/v1.0/groups?`$filter=mailNickname eq '$GroupMailNickName'"
$Data = Invoke-RestMethod -Uri $GetGroupUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method GET
$Group = ($Data | select-object Value).Value
$AddMembersGroupId = $Group.id
## Retrieving the id's of the member's accounts and add the account to the group
$Users = "xxxxx@xxxxx.xxx", "xxxxx@xxxxx.xxx", "xxxxx@xxxxx.xxx"
Foreach ($User in $Users) {
	$GetUsersUrl="https://graph.microsoft.com/v1.0/users/$user"
	$Data2 = Invoke-RestMethod -Uri $GetUsersUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method Get 
	$UserId = $data2.id
	# Add useraccount (userid) to group
	$AddMembersGroupBody  = @{
			"@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$UserId"
	}
	$AddMembersGroupUrl = "https://graph.microsoft.com/v1.0/groups/$AddMembersGroupId/members/`$ref"
	$AddMembersGroup = Invoke-RestMethod -Uri $AddMembersGroupUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method Post -Body $($AddMembersGroupBody | convertto-json) -ContentType "application/json"
}


# Example 3: Remove Member Security Group
## Variables
$RemoveUser = "xxxxx@xxxxx.xxx"
$RemoveGroup = "Marketing"
##
## Retrieving the id of the 'Marketing" group
$GetGroupUrl = "https://graph.microsoft.com/v1.0/groups?`$filter=mailNickname eq '$RemoveGroup'"
$Data3a = Invoke-RestMethod -Uri $GetSecurityGroupUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method GET
$Group = ($Data3a | select-object Value).Value
$RemoveMemberGroupId = $Group.id
## Retrieving the id of the User
$GetRemoveUserUrl="https://graph.microsoft.com/v1.0/users/$RemoveUser"
$Data3b = Invoke-RestMethod -Uri $GetRemoveUserUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method Get 
$RemoveUserId = $Data3b.id
## Removing the User from the 'Marketing'Group
$RemoveMemberFromGroupUrl = "https://graph.microsoft.com/v1.0/groups/$RemoveMemberGroupId/members/$RemoveUserId/`$ref"
$RemoveMemberFromGroup = Invoke-RestMethod -Uri $RemoveMemberFromGroupUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method Delete


# Example 4: Delete Single Group
## Retrieving the id of the "Marketing" group
$DeleteGroupMailNickName = 'Marketing'
$GetDeleteGroupUrl = "https://graph.microsoft.com/v1.0/groups?`$filter=mailNickname eq '$DeleteGroupMailNickName'"
$Data4 = Invoke-RestMethod -Uri $GetDeleteGroupUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method GET
$Result4 = ($Data | select-object Value).Value
$DeleteGroupId = $Result3.id
## Delete the "Marketing" group
$DeleteGroupUrl = "https://graph.microsoft.com/v1.0/groups/$DeleteGroupId"
$DeleteGroup = Invoke-RestMethod -Uri $DeleteGroupUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method Delete
