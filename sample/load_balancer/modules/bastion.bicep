@description('Location for all resources')
param location string

@description('Name of the virtual machine')
param bastionVmName string

@description('The size of the virtual machine')
param vmSize string

@description('Name of the admin username for the virtual machine')
param adminUserName string

@description('Public SSH key for VM')
param sshPublicKey string

@description('The ID of subnet')
param subnetId string

var bastionPublicIpAddrName = '${bastionVmName}-publicIpAddr'
var nicName = '${bastionVmName}-nic'

// IP Address
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
          publicIPAddress: {
            id: bastionPublicIpAddr.id
          }
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

// VM
resource bastionVm 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: bastionVmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: bastionVmName
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
