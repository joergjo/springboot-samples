@description('Specifies the location to deploy to.')
param location string = resourceGroup().location

@description('Specifies the Container App\'s name and common name prefix of all resources.')
@minLength(5)
@maxLength(20)
param name string

@description('Specifies the Container App\'s container image.')
param image string

@description('Specifies the database name to use.')
param database string

@description('Specifies the PostgreSQL login name.')
@secure()
param postgresLogin string

@description('Specifies the PostgreSQL login password.')
@secure()
param postgresLoginPassword string

@description('Specifies the client IP address to whitelist in the database server\'s firewall.')
param clientIP string = ''

module network 'modules/network.bicep' = {
  name: 'network'
  params: {
    location: location
    namePrefix: name
    deployDnsZone: (clientIP == '')
  }
}

module postgres 'modules/database.bicep' = {
  name: 'postgres'
  params: {
    location: location
    database: database
    postgresLogin: postgresLogin
    postgresLoginPassword:postgresLoginPassword
    clientIP: clientIP
    postgresSubnetId: network.outputs.databaseSubnetId
    privateDnsZoneId: network.outputs.privateDnsZoneId
    deployDatabase: true
  }
}

module environment 'modules/environment.bicep' = {
  name: 'environment'
  params: {
    location: location
    namePrefix: name  
    infrastructureSubnetId: network.outputs.infraSubnetId
  }
}

var secrets = {
  postgres: {
    host: postgres.outputs.serverFqdn
    username: postgresLogin
    password: postgresLoginPassword
  }
  appinsights: {
    connectionString: environment.outputs.appInsightsConnectionString
  }
}

module app 'modules/app.bicep' = {
  name: 'app'
  params: {
    name: name
    location: location
    environmentId: environment.outputs.environmentId
    image: image
    database: database
    secrets: secrets
  }
}

output fqdn string = app.outputs.fqdn
