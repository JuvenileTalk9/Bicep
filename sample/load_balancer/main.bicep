@description('Location for all resources')
param location string = resourceGroup().location

@description('Prefix for all resources')
param myName string = 'sandbox'

@description('The size of the virtual machine')
param vmSize string = 'Standard_B1s'

@minValue(1)
@maxValue(3)
@description('Number of the virtual machine')
param wevVmCount int = 2

@description('Name of the admin username for the virtual machine')
param adminUserName string = 'azureuser'

@description('Public SSH key for VM')
param sshPublicKey string

var natGatewayName = '${myName}-natGateway'
var vnetName = '${myName}-VNet'
var webVmName = '${myName}-webVm'
var bastionVmName = '${myName}-bastionVm'
var loadBalancerName = '${myName}-loadBalancer'

// Nat Gateway
module createNatGateway 'modules/nat_gateway.bicep' = {
  name: 'createNatGateway'
  params: {
    location: location
    natGatewayName: natGatewayName
  }
}

// VNet
module createVNet 'modules/vnet.bicep' = {
  name: 'createVNet'
  params: {
    location: location
    vnetName: vnetName
    natGatewayId: createNatGateway.outputs.natGatewayId
  }
  dependsOn: [
    createNatGateway
  ]
}

// Load Balancer
module createLoadBalancer 'modules/load_balancer.bicep' = {
  name: 'createLoadBalancer'
  params: {
    location: location
    loadBalancerName: loadBalancerName
  }
}

// VM
module createVM 'modules/vm.bicep' = [
  for i in range(1, wevVmCount): {
    name: 'createVM-${i}'
    params: {
      location: location
      adminUserName: adminUserName
      sshPublicKey: sshPublicKey
      subnetId: createVNet.outputs.privateSubnetId
      vmName: '${webVmName}-${i}'
      vmSize: vmSize
      vmZone: '${i}'
      backendAddressPoolId: createLoadBalancer.outputs.backendAddressPoolId
    }
    dependsOn: [
      createVNet
      createLoadBalancer
    ]
  }
]

// Bastion
module createBastion 'modules/bastion.bicep' = {
  name: 'createBastion'
  params: {
    location: location
    adminUserName: adminUserName
    bastionVmName: bastionVmName
    sshPublicKey: sshPublicKey
    subnetId: createVNet.outputs.publicSubnetId
    vmSize: vmSize
  }
  dependsOn: [
    createVNet
  ]
}
