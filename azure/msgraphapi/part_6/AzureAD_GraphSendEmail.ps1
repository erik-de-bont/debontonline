# Example file from www.debontonline.com
# Setup Microsoft 365 environment https://developer.microsoft.com/en-us/microsoft-365/dev-program
# Microsoft graph api documentation: https://docs.microsoft.com/en-us/graph/overview?view=graph-rest-1.0
# Base64 encode/decode  https://www.base64encode.org/

# Minimum Required API permission for execution to create a new users
# Mail.ReadWrite

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


# Example 1: Send E-mail Message
$MailSenderUPN = "xxxxx@xxxxxx.xxx"
$SendMailBody = @{
	Message = @{
		Subject = "Test Message"
		Body = @{
			ContentType = "Text"
			Content =  "This is a test e-mail via Microsoft Graph API!"
		}
		ToRecipients = @(
			@{
				EmailAddress = @{
					Address = "adelev@debontonlinedev.onmicrosoft.com"
				}
			}
		)
		CcRecipients = @(
			@{EmailAddress = @{
					Address = "danas@debontonlinedev.onmicrosoft.com"
			   }
			},
			@{EmailAddress = @{
                    Address = "fannyd@debontonlinedev.onmicrosoft.com"
               }
            }   
		)
	}
$SendMailUrl = "https://graph.microsoft.com/v1.0/users/$MailSenderUPN/SendMail"
$SendMail = Invoke-RestMethod -Uri $SendMailUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method Post -Body $($SendMailBody | convertto-json -depth 4) -ContentType "application/json"
	
	

# Example 2: Send E-mail Attachment
$MailSenderUPN = "xxxxx@xxxxxx.xxx"
$SendMailWithAttachentBody = @{
	Message = @{
		Subject = "HTML Test Message"
		Body = @{
			ContentType = "HTML"
			Content = "This is a test <b>e-mail</b> via Microsoft Graph API!"
		}
		ToRecipients = @(
			@{
				EmailAddress = @{
					Address = "meganb@debontonlinedev.onmicrosoft.com"
				}
			}
		)
		Attachments = @(
			@{
				"@odata.type" = "#microsoft.graph.fileAttachment"
				Name = "attachment.txt"
				ContentType = "text/plain"
				ContentBytes = "SGVsbG8gV29ybGQh"
			}
		)
	}
}
$SendMailWithAttachmentUrl = "https://graph.microsoft.com/v1.0/users/$MailSenderUPN/SendMail"
$SendMailWithAttachment = Invoke-RestMethod -Uri $SendMailWithAttachmentUrl -Headers @{Authorization = "Bearer $($TokenAccess)" }  -Method Post -Body $($SendMailWithAttachentBody  | convertto-json -depth 4) -ContentType "application/json"

