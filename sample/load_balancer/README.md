# load_balancer

## Overview

Create the following resources.

![https://raw.githubusercontent.com/JuvenileTalk9/Bicep/refs/heads/main/sample/load_balancer/deploy_load_balancer.jpg](https://raw.githubusercontent.com/JuvenileTalk9/Bicep/refs/heads/main/sample/load_balancer/deploy_load_balancer.jpg)

## Command

```bash
# Pre-generate SSH key pair
ssh-keygen -m PEM -t rsa -b 4096 -f ~/.ssh/id_rsa.pem

# Generate resource-group
az group create --name deploy_load_balancer --location japaneast

# Deploy
sshPublicKey=$(cat ~/.ssh/id_rsa.pub)
az deployment group create --name load_balancer --resource-group deploy_load_balancer --template-file main.bicep --parameters sshPublicKey="${sshPublicKey}"

# Test
curl -X GET http://<global_ip_addr>/
# <html><body><h2>Welcome to Azure! My name is sandbox-webVm-1.</h2></body></html>
```

## Reference

- Marketplace イメージの検索
    - [https://learn.microsoft.com/ja-jp/azure/virtual-machines/linux/cli-ps-findimage](https://learn.microsoft.com/ja-jp/azure/virtual-machines/linux/cli-ps-findimage)
- クイックスタート
    - [https://learn.microsoft.com/en-us/azure/load-balancer/quickstart-load-balancer-standard-internal-bicep?tabs=CLI](https://learn.microsoft.com/en-us/azure/load-balancer/quickstart-load-balancer-standard-internal-bicep?tabs=CLI)
