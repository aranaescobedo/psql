@description('User assigned managed identity name')
param idName string

@description('The geo-location where the assigned managed identity resides')
param location string

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: idName
  location: location
}

// Output variables 
output id string = id.id
