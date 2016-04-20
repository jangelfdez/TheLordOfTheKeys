
# 1. Check that Azure PS Module is version 1.1.0 or above:" -NoNewline

(Get-Module -Name "Azure" -ListAvailable).Version

# 2. Login to Azure 

Login-AzureRmAccount -SubscriptionId "ID"

# 3. Create a new resource group to store Key Vault

New-AzureRmResourceGroup -Name "jangelfdez-keys" -Location "North Europe"
Get-AzureRmResourceGroup -Name "jangelfdez-keys"

# 4. Create a new key vault

New-AzureRmKeyVault -VaultName 'jangelfdez-key-vault' -ResourceGroupName 'jangelfdez-keys' -Location 'North Europe' `
                    -EnabledForDeployment `
                    -EnabledForTemplateDeployment `
                    -EnabledForDiskEncryption `
                    -Sku premium
Get-AzureRmKeyVault -VaultName 'jangelfdez-key-vault' -ResourceGroupName 'jangelfdez-keys'

# 5. Create a software protected key

$softKey = Add-AzureKeyVaultKey -VaultName "jangelfdez-key-vault" -Name "softwareProtectedkey" -Destination Software
Get-AzureKeyVaultKey -VaultName "jangelfdez-key-vault" -Name "softwareProtectedkey"

# 6. Upload a local software protected key

$cert = Get-ChildItem -Path Cert:\LocalMachine\my\AC8A72D64AC19CABD9C2E5469981718FFD451895
Export-PfxCertificate -Cert $cert -FilePath "$env:HOMEPATH\Desktop\jangelfdez-key-vault.pfx" -Password (Read-Host "Define a password" -AsSecureString)

$softLocalKey = Add-AzureKeyVaultKey -VaultName "jangelfdez-key-vault" -Name "softwareLocalProtectedKey" `
                                     -KeyFilePath "$env:HOMEPATH\Desktop\jangelfdez-key-vault.pfx" `
                                     -KeyFilePassword (Read-Host "Introduce .pfx password" -AsSecureString) `
                                     -Destination Software
Get-AzureKeyVaultKey -VaultName "jangelfdez-key-vault" -Name "softwareLocalProtectedKey"

# 7. Referencing our keys
 
$softKey.Key.Kid
$softLocalKey.Key.Kid

# 8. Storing secrets 

$secret = Set-AzureKeyVaultSecret -VaultName "jangelfdez-key-vault" -Name "sql-admin-password" -SecretValue (Read-Host "Define a password" -AsSecureString)
Get-AzureKeyVaultSecret -VaultName "jangelfdez-key-vault" -Name "sql-admin-password"

# 9. Referencing our secrets

$secret.Id

# 10. Getting information from our keys and secrets

Get-AzureKeyVaultKey -VaultName "jangelfdez-key-vault" | Select Name, Id
Get-AzureKeyVaultSecret -VaultName "jangelfdez-key-vault" | Select Name, Id

Get-AzureKeyVaultKey -VaultName "jangelfdez-key-vault" -Name "softwareProtectedkey"
Get-AzureKeyVaultKey -VaultName "jangelfdez-key-vault" -Name "softwareLocalProtectedkey"

Get-AzureKeyVaultSecret -VaultName "jangelfdez-key-vault" -Name "sql-admin-password"

# 11. Authorize applications to use our keys and secrets

Get-AzureRmADServicePrincipal -SearchString jangelfdezarmaccess

Set-AzureRmKeyVaultAccessPolicy -VaultName "jangelfdez-key-vault" -ServicePrincipalName b68b5181-ae49-4898-800a-9f7cacac5862 -PermissionsToKeys decrypt,sign,encrypt
Set-AzureRmKeyVaultAccessPolicy -VaultName "jangelfdez-key-vault" -ServicePrincipalName b68b5181-ae49-4898-800a-9f7cacac5862 -PermissionsToSecrets Get,list

# 12. Using the HSM option available on Premium SKU

$key = Add-AzureKeyVaultKey -VaultName "jangelfdez-key-vault" -Name 'HSMProtectedKey' -Destination 'HSM'
$key = Add-AzureKeyVaultKey -VaultName "jangelfdez-key-vault" -Name 'HSMLocalProtectedKey' `
                            -KeyFilePath "$env:HOMEPATH\Desktop\jangelfdez-key-vault.pfx" -KeyFilePassword (Read-Host "Introduce .pfx password" -AsSecureString) `                            -Destination 'HSM'

#e.g Not available without an Thales HSM
$key = Add-AzureKeyVaultKey -VaultName "jangelfdez-key-vault" -Name 'HSMByokKey' -KeyFilePath 'c:\ITByok.byok' -Destination 'HSM'

# 13. Delete everything

Remove-AzureRmKeyVault -VaultName "jangelfdez-key-vault"

Remove-AzureRmResourceGroup -ResourceGroupName "jangelfdez-keys" 