@description('Specifies the name prefix of all resources.')
@minLength(5)
@maxLength(20)
param namePrefix string

@description('Specifies the location to deploy to.')
param location string

@description('Specifies the subnet resource ID for the Container App environment.')
param infrastructureSubnetId string

@description('Specifies the Datadog API Key.')
@secure()
param ddApiKey string

@description('Specifies the Datadog site.')
param ddSite string

// HACK
var deployAppInsights = false
var deployOpenTelemetry = !empty(ddApiKey) && !empty(ddSite)

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${namePrefix}-logs'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${namePrefix}-insights'
  location: location
  kind: 'java'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

var appInsightsConfiguration = deployAppInsights ? {
  connectionString: appInsights.properties.ConnectionString
} : null

var openTelemetryConfiguration = deployOpenTelemetry ? {
  destinationsConfiguration: {
    dataDogConfiguration: {
      site: ddSite
      key: ddApiKey
    }
  }
  tracesConfiguration: {
    destinations: ['dataDog']
  }
  metricsConfiguration: {
    destinations: ['dataDog']
  }
} : null

resource environment 'Microsoft.App/managedEnvironments@2023-11-02-preview' = {
  name: '${namePrefix}-env'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    appInsightsConfiguration: appInsightsConfiguration
    openTelemetryConfiguration: openTelemetryConfiguration
    vnetConfiguration: {
      infrastructureSubnetId: infrastructureSubnetId
    }
  }
}

output environmentId string = environment.id
output appInsightsConnectionString string = appInsights.properties.ConnectionString
