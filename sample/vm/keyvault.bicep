@description('Location for all resources')
param location string = resourceGroup().location

@description('Key Vault Name')
param keyVaultName string

// KeyVault
resource keyvault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
  }
}
