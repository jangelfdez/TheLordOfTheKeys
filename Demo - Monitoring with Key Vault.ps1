# 1. Check that Azure PS Module is version 1.1.0 or above:"

(Get-Module -Name "Azure" -ListAvailable).Version

# 2. Login to Azure  

Login-AzureRmAccount -SubscriptionId "Id"

# 3. Create a new storage account for storing the logs

New-AzureRmStorageAccount -ResourceGroupName "jangelfdez-monitoring" -Name "jangelfdezmonitoring"
Get-AzureRmStorageAccount -ResourceGroupName "jangelfdez-monitoring" -Name "jangelfdezmonitoring"

# 4. Activate logging cappabilities for the vault

$keyVault = Get-AzureRmKeyVault -VaultName "jangelfdez-key-vault"
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName "jangelfdez-monitoring" -Name "jangelfdezmonitoring"

Set-AzureRmDiagnosticSetting -ResourceId $keyVault.ResourceId -StorageAccountId $storageAccount.id -Enabled $true -Categories AuditEvent

# 5. Viewing the audit logs

$storageAccountName = $storageAccount.StorageAccountName
$storageAccountPrimaryKey = (Get-AzureRmStorageAccountKey -ResourceGroupName "jangelfdez-monitoring" -Name "jangelfdezmonitoring").Key1

$storageContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountPrimaryKey

Get-AzureStorageBlob -Container 'insights-logs-auditevent' -Context $storageContext.Context | Select LastModified, Length, Name

# 6. Downloading the audit logs

New-Item -Path "$env:HOMEPATH\Desktop\jangelfdez-key-vault-logs" -ItemType Directory -Force

$blobs = Get-AzureStorageBlob -Container 'insights-logs-auditevent' -Context $storageContext.Context
$blobs | Get-AzureStorageBlobContent -Destination "$env:HOMEPATH\Desktop\jangelfdez-key-vault-logs"

# 7. Showing an example of record

Get-ChildItem -Path "$env:HOMEPATH\Desktop\jangelfdez-key-vault-logs"

notepad.exe "$env:HOMEPATH\Desktop\jangelfdez-key-vault-logs\yourFile"

$rawContent = Get-Content -Path "$env:HOMEPATH\Desktop\jangelfdez-key-vault-logs\yourFile" | Out-String

$json = ConvertFrom-Json $rawContent

$json.records[0].callerIpAddress
$json.records[0].operationName
$json.records[0].time