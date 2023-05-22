@description('Enabled for Azure AD authentication support, Azure AD Administrators Name (Azure member or group name)')
param adminAdGroupName string

@description('Azure AD Administrators resource id')
param adminAdGroupObjectId string

@description('Server administrator login name')
param adminLogin string

@description('Server administrator login name')
@secure()
param adminPassword string

@description('Availability zone information of the server.')
param availabilityZone string

@description('Backup retention days for the server')
param backupRetentionDays int

@description('Indicating whether Geo-Redundant backup is enabled on the server')
param enableGeo bool

@description('URI for the key for data encryption for server')
param keyVaultKeyURI string

@description('Data encryption type to depict if it is System Managed vs Azure Key vault')
@allowed([
  'AzureKeyVault'
  'SystemManaged'
])
param keyVaultType string

@description('The geo-location where the server lives')
param location string

@description('PostgreSQL Server name')
param psqlName string

@description('PostgreSQL Server version')
@allowed([
  '11'
  '12'
  '13'
  '14'
])
param psqlVersion string

@description('Private dns zone resource id')
param privateDnsZoneSourceId string

@description('Name of the sku, typically, tier + family + cores, e.g. Standard_D4s_v3')
param skuName string

@description('Tier of the particular SKU, e.g. Burstable.')
@allowed([
  'Burstable'
  'GeneralPurpose'
  MemoryOptimized'
])
param skuTier string

@description('Max storage allowed for a server')
param storageSizeGB int

@description('Delegated subnet arm resource id')
param subnetSourceId string

@description('Server tags')
param tags object

@description('Tenant id of the server')
param tenantId string

@description('Delegated User assigned identity resource id')
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
    administratorLogin: adminLogin
    administratorLoginPassword: adminPassword
    availabilityZone: availabilityZone
    authConfig: {
      activeDirectoryAuth: 'Enabled'
      passwordAuth: 'Enabled'
      tenantId: tenantId
    }
    dataEncryption: {
      type: keyVaultType
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
    version: psqlVersion
    }
    resource adAdmin 'administrators' = {
      name:  adGroupObjectId
      properties: {
        principalName: adGroupName
        principalType: 'Group'
        tenantId: tenantId
      }
    }
  }
