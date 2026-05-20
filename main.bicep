// =============================================================================
// Example consumer of the org-standard Key Vault shared module.
// The module reference uses the `shared` alias defined in bicepconfig.json,
// which points to the private ACR populated by the producer pipeline.
// =============================================================================

targetScope = 'resourceGroup'

@description('Application name (used in vault naming).')
param appName string

@description('Environment short code: dev | tst | prd.')
@allowed([ 'dev', 'tst', 'prd' ])
param env string

@description('Azure region.')
param location string = resourceGroup().location

@description('Log Analytics workspace resource ID for diagnostics.')
param logAnalyticsWorkspaceResourceId string = ''

@description('Tags applied to all resources.')
param tags object = {}

// -- Pinned shared module version. Renovate updates this line. ---------------
module kv 'br/shared:keyvault-shared:0.11.0' = {
  name: 'kv-${appName}-${env}'
  params: {
    name:     'kv-${appName}-${env}-${uniqueString(resourceGroup().id, appName)}'
    location: location
    tags:     tags
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
  }
}

output keyVaultId  string = kv.outputs.resourceId
output keyVaultUri string = kv.outputs.uri
