# Example file from www.debontonline.com 
# Setup Microsoft 365 environment https://developer.microsoft.com/en-us/microsoft-365/dev-program
# Microsoft graph api documentation: https://docs.microsoft.com/en-us/graph/overview?view=graph-rest-1.0
# Base64 encode/decode  https://www.base64encode.org/

# Minimum Required API permission for execution
# Application.ReadWrite.All
# AppRoleAssignment.ReadWrite.All


# Variables
$DisplayName = "Test Application - 1" # Name of the new Enterprise Application



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


# Example 1 - Create Enterprise Application / App Registration
## Create Application Registration
$AppRegBody  = @{
        "displayName" = $DisplayName    
}

$apiAppRegUrl = "https://graph.microsoft.com/v1.0/applications"
$App = Invoke-RestMethod -Uri $apiAppRegUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method POST -Body $($AppRegBody | convertto-json) -ContentType "application/json"


## Create Enterprise Application (Service PrincipalName)
$SPNBody   = @{
        appId = $($app.appid)   
}

$apiSPNUrl = "https://graph.microsoft.com/v1.0/servicePrincipals"
$SPN = Invoke-RestMethod -Uri $apiSPNUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method POST -Body $($SPNBody | convertto-json) -ContentType "application/json"



## Set API Permissions
$AppObjectId = $app.id 

$AppPermBody= @{ 
   requiredResourceAccess = @( 
        @{
        "resourceAppId"  = "00000003-0000-0000-c000-000000000000" # MS Graph app id.
        "resourceAccess" =   @(
                             @{
                            "id"   = "df021288-bdef-4463-88db-98f22de89214" # User.Read.All id.
                           "type" = "Role"
                            }
                            )
                      
    }    
  )
}

 
$apiPermUrl = "https://graph.microsoft.com/v1.0/applications/$AppObjectId"
$APIPerm = Invoke-RestMethod -Uri $apiPermUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method PATCH -Body $($AppPermBody | convertto-json -depth 4 ) -ContentType "application/json"



## Grant Scope rights with Admin Consent Delegation Permissions
<#$ScopeBody = @{
  "clientId"    = $($SPN.id)
  "consentType" = "AllPrincipals"
  "principalId" = $null
  "resourceId"  = $ResourceId
  "scope"       = "User.Read.All"
  "expiryTime"  = "2299-12-31T00:00:00Z"
}

$apiUrl = "https://graph.microsoft.com/v1.0/oauth2PermissionGrants"
$Scope = Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method POST -Body $($ScopeBody | convertto-json) -ContentType "application/json"

#>


## Grant Scope rights with Admin Consent Application Permissions
$SPNObjectId = $SPN.id
$ScopeBody = @{
  "principalId" =  $SPNObjectId
  "resourceId"  =  $ResourceID
  "appRoleId"  =   $AppPermissionsRequiredId
}


$apiUrl = "https://graph.microsoft.com/v1.0/servicePrincipals/$SPNObjectId/appRoleAssignments"
$Scope = Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method POST -Body $($ScopeBody | convertto-json) -ContentType "application/json"


## Set Owner Application
$OwnerUPN = "owner@$tenantname"
$getUserUrl = "https://graph.microsoft.com/v1.0/users/$OwnerUPN"
$ProfileOwner = Invoke-RestMethod -Uri $getUserUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method GET


$OwnerId = $ProfileOwner.Id
$OwnerBody = @{
	"@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$OwnerId"
}

$appobjectId = $app.Id

$apiOwnerUrl = "https://graph.microsoft.com/v1.0/applications/$appObjectId/owners/`$ref"
$Owner = Invoke-RestMethod -Uri $apiOwnerUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method POST -Body $($OwnerBody | convertto-json) -ContentType "application/json"

$SPNOwnerUrl = "https://graph.microsoft.com/beta/servicePrincipals/$SPNObjectId/owners/`$ref"
$SPNOwner = Invoke-RestMethod -Uri $SPNOwnerUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method POST -Body $($OwnerBody | convertto-json) -ContentType "application/json"


## Grant Users and/or Groups access to the Application

