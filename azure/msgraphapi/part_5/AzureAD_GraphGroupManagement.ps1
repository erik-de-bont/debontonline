# Example file from www.debontonline.com
# Setup Microsoft 365 environment https://developer.microsoft.com/en-us/microsoft-365/dev-program
# Microsoft graph api documentation: https://docs.microsoft.com/en-us/graph/overview?view=graph-rest-1.0



# Minimum Required API permission for execution to create a new users
# Group.Create
# Group.ReadWrite.All
# Directory.ReadWrite.All


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
	Description = "Marketing "
	DisplayName = "Marketing group"
	GroupTypes = @(
	)
	MailEnabled = $false
	MailNickname = "marketing"
	SecurityEnabled = $true
	"Owners@odata.bind" = @(
		"https://graph.microsoft.com/v1.0/users/AdeleV@erikdebontdev.onmicrosoft.com"
	)
	"Members@odata.bind" = @(
		"https://graph.microsoft.com/v1.0/users/GradyA@erikdebontdev.onmicrosoft.com"
		"https://graph.microsoft.com/v1.0/users/HenriettaM@erikdebontdev.onmicrosoft.com"
	)
}

$CreateSecurityGroupUrl = "https://graph.microsoft.com/v1.0/groups"
$CreateSecurityGroup = Invoke-RestMethod -Uri $CreateSecurityGroupUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method Post -Body $($CreateSecurityGroupBody | convertto-json) -ContentType "application/json"

# Example 2: Modify Members Security Group


# Example 3: Create Single Microsoft 365 Group

# Example 4: Delete Single Group

# Example 4: Create multiple Security Groups via CSV