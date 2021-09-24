param name string = 'myv2datafactory'
param version string = 'V2'
param location string = 'eastus'
param apiVersion string = '2018-06-01'
param tagsByResource object
param vNetEnabled bool = false
param publicNetworkAccess bool = true
param gitConfigureLater bool = true
param gitRepoType string = 'FactoryVSTSConfiguration'
param gitAccountName string = ''
param gitProjectName string = ''
param gitRepositoryName string = ''
param gitCollaborationBranch string = 'master'
param gitRootFolder string = '/'
param userAssignedIdentities object = {
  type: 'SystemAssigned'
}
param userAssignedIdentitiesStr string = ''
param vaultBaseUrl string = ''
param keyName string = ''
param keyVersion string = ''
param enableCMK bool = false
param cmkIdentity string = ''

resource name_resource 'Microsoft.DataFactory/factories@2018-06-01' = if (version == 'V2') {
  name: name
  location: location
  identity: (enableCMK ? json(userAssignedIdentitiesStr) : userAssignedIdentities)
  properties: {
    repoConfiguration: (bool(gitConfigureLater) ? json('null') : json('{"type": "${gitRepoType}","accountName": "${gitAccountName}","repositoryName": "${gitRepositoryName}",${((gitRepoType == 'FactoryVSTSConfiguration') ? '"projectName": "${gitProjectName}",' : '')}"collaborationBranch": "${gitCollaborationBranch}","rootFolder": "${gitRootFolder}"}'))
    publicNetworkAccess: (bool(publicNetworkAccess) ? 'Enabled' : 'Disabled')
    encryption: (bool(enableCMK) ? json('{"identity":{"userAssignedIdentity":"${cmkIdentity}"},"VaultBaseUrl": "${vaultBaseUrl}","KeyName": "${keyName}","KeyVersion": "${keyVersion}"}') : json('null'))
  }
  tags: (contains(tagsByResource, 'Microsoft.DataFactory/factories') ? tagsByResource.Microsoft.DataFactory/factories : json('{}'))
}

resource name_default 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' = if (version == 'V2') {
  parent: name_resource
  name: 'default'
  properties: {}
}

resource name_AutoResolveIntegrationRuntime 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = if (version == 'V2') {
  parent: name_resource
  name: 'AutoResolveIntegrationRuntime'
  properties: {
    type: 'Managed'
    managedVirtualNetwork: {
      referenceName: 'default'
      type: 'ManagedVirtualNetworkReference'
    }
    typeProperties: {
      computeProperties: {
        location: 'AutoResolve'
      }
    }
  }
  dependsOn: [
    name_default
  ]
}

resource Microsoft_DataFactory_dataFactories_name 'Microsoft.DataFactory/dataFactories@2015-01-01-preview' = if (version == 'V1') {
  name: name
  location: ((version == 'V1') ? location : 'eastus')
  properties: {}
  tags: (contains(tagsByResource, 'Microsoft.DataFactory/dataFactories') ? tagsByResource.Microsoft.DataFactory/dataFactories : json('{}'))
}