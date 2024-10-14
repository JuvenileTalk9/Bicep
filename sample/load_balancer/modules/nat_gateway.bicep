@description('Location for all resources')
param location string

@description('Name of the NAT Gateway')
param natGatewayName string

var natGatewayPublicIpAddrName = '${natGatewayName}-publicIpAddr'

// IP Address
resource natGatewayPublicIpAddr 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: natGatewayPublicIpAddrName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// NAT Gateway
resource natGateway 'Microsoft.Network/natGateways@2023-11-01' = {
  name: natGatewayName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIpAddresses: [
      {
        id: natGatewayPublicIpAddr.id
      }
    ]
  }
}

output natGatewayId string = natGateway.id
