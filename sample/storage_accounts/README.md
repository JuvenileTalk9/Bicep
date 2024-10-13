# storage_account

## Overview

Create the following resources.

- ストレージアカウント1つ
- Blobコンテナ1つ

## Command

```bash
az group create --name deploy_storage_account --location japaneast

az deployment group create --name storage_accounts --resource-group deploy_storage_account --template-file storage_accounts.bicep
```

## Reference

- [https://learn.microsoft.com/ja-jp/azure/templates/microsoft.storage/storageaccounts?pivots=deployment-language-bicep](https://learn.microsoft.com/ja-jp/azure/templates/microsoft.storage/storageaccounts?pivots=deployment-language-bicep)
