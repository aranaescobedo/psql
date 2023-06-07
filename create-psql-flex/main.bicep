targetScope = 'subscription'

@description('Enabled for Azure AD authentication support, Azure AD Administrator`s Name')
param adminAdGroupName string

@description('Azure AD Administrators resource id')
param adminAdGroupObjectId string

@description('Azure AD type')
@allowed([
  'Group'
  'ServicePrincipal'
  'User'
])
param adminAdType string

@description('Server administrator login name')
param adminLogin string

@description('Server administrator login name')
@secure()
param adminPassword string

@description('Resource group name where the user identity and psql resources will be stored')
param dbResourceGroupName string

@description('Used to get a random guid in the end of the deployment names')
param dateTime string = utcNow()

@allowed([
  'test'
  'prod'
])
@description('Target environment for your deployment')
param env string

@description('Customer Managed Key Name (CMK)')
param keyName string

@description('Key Vault name where the CMK is located')
param kvName string

@description('Resource group name where the key vault is located')
param kvResourceGroupName string

@description('Subscription ID where the key vault is located')
param kvSubscriptionId string

@description('Data encryption type to depict if it is System Managed vs Azure Key vault')
@allowed([
  'AzureKeyVault'
  'SystemManaged'
])
param keyVaultType string

@description('The geo-location where the server lives')
param location string = deployment().location

@description('Resource group name where the network resources will be stored')
param networkresourceGroupName string

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

@description('Reference to the RouteTable resource id')
param rtName string

@description('Address prefix for the subnet')
param snetAddressPrefix string

@description('Subnet name')
param snetName string

@description('The User assigned identity Name that have permission to the CMK in the Key Vault')
param userAssignedIdentityName string

@description('Virtual network name')
param vnetName string

var envPsqlConfig = {
  test: {
    availabilityZone: '1'
    backupRetentionDays: 7
    geoRedundantBackup: false
    name: 'Standard_B2s'
    tier: 'Burstable'
    storageSizeGB: 32
  }
  prod: {
    availabilityZone: '2'
    backupRetentionDays: 32
    geoRedundantBackup: true //As support for Geo-redundant backup with data encryption using CMK is currently in preview
    name: 'Standard_D2s_v3'
    tier: 'GeneralPurpose'
    storageSizeGB: 64
  }
}

var tags = {
  Department: 'Operations'
  Environment: env
}

resource kv 'Microsoft.KeyVault/vaults@2022-11-01' existing = {
  name: kvName
  scope: resourceGroup(kvSubscriptionId, kvResourceGroupName)
  resource key 'keys@2022-11-01' existing = {
    name: keyName
  }
}

//Get private DNS zone source id
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  scope: resourceGroup(networkresourceGroupName)
  name: 'privatelink.postgres.database.azure.com'
}

//Get user assigned Identity
resource userManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup(dbResourceGroupName)
  name: userAssignedIdentityName
}

//Create Subnet with route table
module subnet 'modules/subnet.bicep' = {
  scope: resourceGroup(networkresourceGroupName)
  name: '${snetName}-${substring(uniqueString(dateTime),0,4)}'
  params: {
    rtName: rtName
    snetAddressPrefix: snetAddressPrefix
    snetName: snetName
    vnetName: vnetName
  }
}

//Create Azure Database for PostgreSQL flexible server
module psql 'modules/psql.bicep' = {
  scope: resourceGroup(dbResourceGroupName)
  name: '${psqlName}-${substring(uniqueString(dateTime),0,4)}'
  params: {
    adminAdGroupName: adminAdGroupName
    adminAdGroupObjectId: adminAdGroupObjectId
    adminAdType: adminAdType
    adminLogin: adminLogin
    adminPassword: adminPassword
    availabilityZone: envPsqlConfig[env].availabilityZone
    backupRetentionDays: envPsqlConfig[env].backupRetentionDays
    enableGeo: envPsqlConfig[env].geoRedundantBackup
    keyVaultKeyURI: kv::key.properties.keyUriWithVersion
    keyVaultType: keyVaultType
    location: location
    privateDnsZoneSourceId: privateDnsZone.id
    psqlName: psqlName
    psqlVersion: psqlVersion
    skuName: envPsqlConfig[env].name
    skuTier: envPsqlConfig[env].tier
    storageSizeGB: envPsqlConfig[env].storageSizeGB
    subnetSourceId: subnet.outputs.id
    tags: tags
    tenantId: tenant().tenantId
    userAssignedIdentityId: userManagedIdentity.id
  }
}
