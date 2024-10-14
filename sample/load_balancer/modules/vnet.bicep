@description('Location for all resources')
param location string

@description('Name of the virtual network')
param vnetName string

@description('The ID of NAT gateway')
param natGatewayId string

var nsgName = '${vnetName}-subnetNsg'
var subnetName = '${vnetName}-subnet'

// NSG
resource privateSubnetNsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: '${nsgName}-private'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowAnyHTTPInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowCidrBlockSSHInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '10.0.1.0/24'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 200
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAnySSHInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 210
          direction: 'Inbound'
        }
      }
    ]
  }
}
resource publicSubnetNsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: '${nsgName}-public'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowAnySSHInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

// VNet
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: '${subnetName}-private'
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: privateSubnetNsg.id
          }
          natGateway: {
            id: natGatewayId
          }
        }
      }
      {
        name: '${subnetName}-public'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: publicSubnetNsg.id
          }
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output privateSubnetId string = vnet.properties.subnets[0].id
output publicSubnetId string = vnet.properties.subnets[1].id
