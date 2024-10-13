@description('Location for all resources')
param location string = resourceGroup().location

@description('Prefix for all resources')
param myName string = 'sandbox'

@description('The size of the virtual machine')
param vmSize string = 'Standard_B1s'

@description('Name of the admin username for the virtual machine')
param adminUserName string = 'azureuser'

@description('Public SSH key for VM')
param sshPublicKey string

var nsgName = '${myName}-nsg-01'
var natGatewayPublicIpAddrName = '${myName}-natGatewayPublicIpAddr-01'
var bastionPublicIpAddrName = '${myName}-bastionPublicIpAddr-01'
var virtualNetworkName = '${myName}-VNet-01'
var subnetName = '${myName}-Subnet-01'
var natGatewayName = '${myName}-NatGateway-01'
var nicName = '${myName}-nic-01'
var vmName = '${myName}-vm-01'
var bastionName = '${myName}-bastion-01'

// NSG
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: []
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

// VNet
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
          natGateway: {
            id: natGateway.id
          }
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

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
resource bastionPublicIpAddr 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: bastionPublicIpAddrName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// NIC
resource nic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig01'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet.properties.subnets[0].id
          }
        }
      }
    ]
  }
}

// VM
resource vm 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUserName
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              keyData: sshPublicKey
              path: '/home/${adminUserName}/.ssh/authorized_keys'
            }
          ]
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

// Bastion
resource bastion 'Microsoft.Network/bastionHosts@2023-11-01' = {
  name: bastionName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    scaleUnits: 2
    ipConfigurations: [
      {
        name: 'ipconfig01'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: bastionPublicIpAddr.id
          }
          subnet: {
            id: vnet.properties.subnets[1].id
          }
        }
      }
    ]
  }
}

output sshPublicKeyOutput string = sshPublicKey
output vmId string = vm.id
