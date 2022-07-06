# Example file from www.debontonline.com 
# Setup Microsoft 365 environment https://developer.microsoft.com/en-us/microsoft-365/dev-program
# Microsoft graph api documentation: https://docs.microsoft.com/en-us/graph/api/overview?view=graph-rest-1.0&preserve-view=true

# Minimum Required API permission for execution to create a new users
# AdministativeUnit.ReadWrite.All
# RoleMangement.ReadWrite.Directory

# Required Powershell Module for certificate authorisation
# Install-Module MSAL.PS 

# Source CSV setup with following headers
# AUName; AUDescription; RoleGroupl RoleGroupdescription; UserQuery

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


# Variables
$Importfile  = "C:\Temp\Import\AdminUnits.csv"

# Example 1: Create Administrative Units
$AdminUnits = Import-Csv -Path $Importfile -Delimiter ";"

ForEach($AdminUnit in $AdminUnits)  { 

	$CreateAdminUnitBody = @{
		displayName = $AdminUnit.AUName
		description = $AdminUnit.AUDescription
		visibility = "HiddenMembership"
		#membershipType = "Dynamic"
		#membershipRule =  $AdminUnit.DeviceQuery
		#membershipRuleProcessingState = "On"
	}

	$CreateAdminUnitUrl = "https://graph.microsoft.com/v1.0/directory/administrativeUnits"
	$CreateAdminUnit = Invoke-RestMethod -Uri $CreateAdminUnitUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method Post -Body $($CreateAdminUnitBody  | convertto-json) -ContentType "application/json"

}

# Example 2: Retrieve Object ID Owner
$OwnerUPN = "AdeleV@debontonlinedev.onmicrosoft.com"
$GetUPNUrl="https://graph.microsoft.com/v1.0/users/$OwnerUPN'"
$Owner = Invoke-RestMethod -Uri $GetUPNUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method Get 
$OwnerId = $Owner.value.id

# Example 3: Create Azure AD AU Role groups
$Groups = Import-Csv -Path $Importfile -Delimiter ";"

ForEach($Group in $Groups)  { 
	$CreateSecurityGroupBody = @{
		Description = $Group.RoleGroupDescription
		DisplayName = $Group.RoleGroup
		GroupTypes = @(
		)
		isAssignableToRole = $true
		MailEnabled = $false
		MailNickname = $Group.RoleGroup
		SecurityEnabled = $true
		"Owners@odata.bind" = @(
			"https://graph.microsoft.com/v1.0/directoryObjects/$OwnerId"
		)
	}
		$CreateSecurityGroupUrl = "https://graph.microsoft.com/v1.0/groups"
		$CreateSecurityGroup = Invoke-RestMethod -Uri $CreateSecurityGroupUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method Post -Body $($CreateSecurityGroupBody | convertto-json) -ContentType "application/json"

}

# Example 4: Add Rolemember to Administrative Unit Role
$RoleDisplayName = "Authentication Admnistrator"
## Get Role Id
$GetRoleUrl = "https://graph.microsoft.com/v1.0//roleManagement/directory/roleDefinitions?`$filter=displayName eq '$RoleDisplayName'"
$Data = Invoke-RestMethod -Uri $GetRoleUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method GET
$Role= ($Data | select-object Value).Value
$RoleId = $Role.id


ForEach($Group in $Groups)  {
	# Get AdminUnitId
    $AdminUnitName=$Group.AUName
	$GetAdminUnitUrl="https://graph.microsoft.com/v1.0/directory/administrativeUnits?`$filter=displayName eq '$AdminUnitName'"
	$Data3 = Invoke-RestMethod -Uri $GetAdminUnitUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method Get 
	$AdminUnitId = $data3.value.id
	
	## Get Rolemember User Id
    #$GetScopeRoleMemberUrl = "https://graph.microsoft.com/v1.0/users/$ScopeRoleMemberUPN"
    #$Data = Invoke-RestMethod -Uri $GetScopeRoleMemberUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method GET
    #$ScopeRoleMemberId = $Data.id
	## Get Rolemember Group Id
	$GroupName = $Group.RoleGroup
	$GetScopeRoleMemberUrl = $GetGroupUrl = "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq '$GroupName'"
    $Data = Invoke-RestMethod -Uri $GetScopeRoleMemberUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method GET
	$ScopeRoleMemberId = $Data.value.id
    ## Add Rolemember to RoleGroup
	$AddScopeRoleMemberBody = @{
		"@odata.type" = "#microsoft.graph.unifiedRoleAssignment"
		RoleDefinitionId = $RoleId
		PrincipalId = $ScopeRoleMemberId
		DirectoryScopeId = "/administrativeUnits/$AdminUnitId"	
	}
	
	$AddScopeRoleMemberUrl = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments"
	$AddScopeRoleMemberUnit = Invoke-RestMethod -Uri $AddScopeRoleMemberUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method Post -Body $($AddScopeRoleMemberBody  | convertto-json) -ContentType "application/json"
}	



