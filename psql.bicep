@secure()
param adminPassword string
param availabilityZone string
param backupRetentionDays int
param dbADGroupName string
param dbADGroupObjectId string
param enableGeo bool
param keyVaultKeyURI string
param location string
param psqlName string
param privateDnsZoneSourceId string
param skuName string
param skuTier string
param storageSizeGB int
param subnetSourceId string
param tags object
param tenantId string
param userAssignedIdentityId string

resource psql 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: psqlName
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}':{}
}
  }
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  tags: tags
  properties: {
    administratorLogin: 'pgadmin'
    administratorLoginPassword: adminPassword
    availabilityZone: availabilityZone
    authConfig: {
      activeDirectoryAuth: 'Enabled'
      passwordAuth: 'Enabled'
      tenantId: tenantId
    }
    dataEncryption: {
      type: 'AzureKeyVault'
      primaryKeyURI: keyVaultKeyURI
      primaryUserAssignedIdentityId: userAssignedIdentityId
    }
    backup: {
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: enableGeo ? 'Enabled' : 'Disabled'
    }
    network: {
      delegatedSubnetResourceId: subnetSourceId
      privateDnsZoneArmResourceId: privateDnsZoneSourceId
    }
    storage: {
      storageSizeGB: storageSizeGB
    }
    version: '14'
    }
    resource iam 'administrators' = {
      name:  dbADGroupObjectId
      properties: {
        principalName: dbADGroupName
        principalType: 'Group'
        tenantId: tenantId
      }
    }
  }

