@description('Location for all resources')
param location string

@description('Name of the load balancer')
param loadBalancerName string

var loadBalancerPublicIpAddrName = '${loadBalancerName}-publicIpAddr'

// IP Address
resource loadBalancerPublicIpAddr 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: loadBalancerPublicIpAddrName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// Load Balancer
resource loadBalancer 'Microsoft.Network/loadBalancers@2023-11-01' = {
  name: loadBalancerName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'LoadBalancerFrontend'
        properties: {
          publicIPAddress: {
            id: loadBalancerPublicIpAddr.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backendAddressPool'
      }
    ]
    loadBalancingRules: [
      {
        name: 'loadBalancingRule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/frontendIpConfigurations',
              loadBalancerName,
              'LoadBalancerFrontend'
            )
          }
          backendAddressPool: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/backendAddressPools',
              loadBalancerName,
              'backendAddressPool'
            )
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: false
          idleTimeoutInMinutes: 4
          disableOutboundSnat: true
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancerName, 'probe')
          }
        }
      }
    ]
    probes: [
      {
        name: 'probe'
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 5
        }
      }
    ]
  }
}

output backendAddressPoolId string = loadBalancer.properties.backendAddressPools[0].id
