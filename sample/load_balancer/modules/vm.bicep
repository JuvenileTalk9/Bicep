@description('Location for all resources')
param location string

@description('Name of the virtual machine')
param vmName string

@description('The size of the virtual machine')
param vmSize string

@description('The zone of virtuial machine')
param vmZone string

@description('Name of the admin username for the virtual machine')
param adminUserName string

@description('Public SSH key for VM')
param sshPublicKey string

@description('The ID of subnet')
param subnetId string

@description('Backend address pool ID of load balancer')
param backendAddressPoolId string

var nicName = '${vmName}-nic'

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
            id: subnetId
          }
          loadBalancerBackendAddressPools: [
            {
              id: backendAddressPoolId
            }
          ]
        }
      }
    ]
  }
}

// VM
resource webVm 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: vmName
  location: location
  zones: [
    vmZone
  ]
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
      customData: loadFileAsBase64('cloud-init.yaml')
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

output vmPrivateIp string = nic.properties.ipConfigurations[0].properties.privateIPAddress
