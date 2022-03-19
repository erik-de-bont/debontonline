# Example file from www.debontonline.com
# Setup Microsoft 365 environment https://developer.microsoft.com/en-us/microsoft-365/dev-program
# Microsoft graph api documentation: https://docs.microsoft.com/en-us/graph/overview?view=graph-rest-1.0



# Minimum Required API permission for execution to create a new users
# User.Read.Write.All
# User.ManageIdentities.All



# Connection information for Graph API connection - specific to Agency
$clientID = "xxxxxxx-xxxx-xxxx-xxxxxxxxx" #  App Id MS Graph API Connector App registration
$tenantName = "<<mytenantname>>.onmicrosoft.com" # your tenantname (example: debontonlinedev.onmicrosoft.com)
$clientSecret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # Secret MS Graph API Connector App registration
$resource = "https://graph.microsoft.com/"
 
$ReqTokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    client_Id     = $clientID
    Client_Secret = $clientSecret
} 
 
$TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantName/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody
$TokenAccess = $Tokenresponse.access_token
 
<#Create User
$CreateUserBody = @{
    "userPrincipalName"="John.Doe@$tenantname"
    "displayName"="John Doe"
    "mailNickname"="John Doe"
    "accountEnabled"=$true
    "passwordProfile"= @{
        "forceChangePasswordNextSignIn" = $false
        "forceChangePasswordNextSignInWithMfa" = $false
        "password"="Welcome123456"
    }
 }

$CreateUserUrl = "https://graph.microsoft.com/v1.0/users"
$User = Invoke-RestMethod -Uri $CreateUserUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method Post -Body $($CreateUserBody | convertto-json) -ContentType "application/json"


