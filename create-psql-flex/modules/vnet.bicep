@description('The geo-location where the virtual network resides')
param location string

@description('Tags for the Virtual Network')
param tags object

@description('A list of address blocks reserved for this virtual network in CIDR notation')
param vnetAddressPrefix string

@description('Name of the Virtual Network')
param vnetName string

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
  tags: tags
}

// Output variables 
output name string = vnet.name
