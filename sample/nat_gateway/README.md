# nat_gateway

## Overview

Create the following resources.

![https://raw.githubusercontent.com/JuvenileTalk9/Bicep/refs/heads/main/sample/nat_gateway/deploy_nat_gateway.jpg](https://raw.githubusercontent.com/JuvenileTalk9/Bicep/refs/heads/main/sample/nat_gateway/deploy_nat_gateway.jpg)

## Command

```bash
# Pre-generate SSH key pair
ssh-keygen -m PEM -t rsa -b 4096 -f ~/.ssh/id_rsa.pem

# Generate resource-group
az group create --name deploy_nat_gateway --location japaneast

# Deploy keyvault
keyVaultName="myKeyVault1223334444"
az deployment group create --name keyvault --resource-group deploy_nat_gateway --template-file keyvault.bicep --parameters keyVaultName="${keyVaultName}"

# Attach admin role
az role assignment create --assignee "<user-object-id>" --role "Key Vault Administrator" --scope "<keyvault-resource-id>"

# Upload private key
az keyvault secret set --vault-name "${keyVaultName}" --name vm-key --file ~/.ssh/id_rsa.pem

# Deploy vnet and vm
sshPublicKey=$(cat ~/.ssh/id_rsa.pub)
az deployment group create --name nat_gateway --resource-group deploy_nat_gateway --template-file nat_gateway.bicep --parameters sshPublicKey="${sshPublicKey}"
```

`<user-object-id>`は`Microsoft Entra ID`から参照可能。

`<keyvault-resource-id>`は対象のキーコンテナの概要からJSONビューなどで参照可能。

## Reference

- Marketplace イメージの検索
    - [https://learn.microsoft.com/ja-jp/azure/virtual-machines/linux/cli-ps-findimage](https://learn.microsoft.com/ja-jp/azure/virtual-machines/linux/cli-ps-findimage)
- ロール割り当て
    - [https://learn.microsoft.com/ja-jp/azure/role-based-access-control/role-assignments-cli](https://learn.microsoft.com/ja-jp/azure/role-based-access-control/role-assignments-cli)

## ToDo

- [ ] `keyvault-resource-id`参照の自動化
