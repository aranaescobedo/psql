@description('Reference to the RouteTable resource ID')
param rtName string

@description('Address prefix for the subnet')
param snetAddressPrefix string

@description('Subnet name')
param snetName string

@description('Virtual network name')
param vnetName string

resource rt 'Microsoft.Network/routeTables@2022-07-01' existing = {
  name: rtName
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: vnetName
  resource subnet 'subnets' = {
    name: snetName
    properties: {
      serviceEndpoints: [
        {
          service: 'Microsoft.KeyVault'
        }
      ]
      addressPrefix: snetAddressPrefix
      delegations: [
        {
          name: 'Microsoft.DBforMySQL.flexibleServers'
          properties: {
            serviceName: 'Microsoft.DBforMySQL/flexibleServers'
          }
        }
      ]
      routeTable: {
        id: rt.id
      }
    }
  }
}

// Output variables 
output id string = vnet::subnet.id
