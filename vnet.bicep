@description('The geo-location where the virtual network lives')
param location string

@description('Virtual Network tags')
param tags object

@description('A list of address blocks reserved for this virtual network in CIDR notation')
param vnetAddressPrefix

@description('Virtual network name')
param vnetName

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
output vnetId string = vnet.id
