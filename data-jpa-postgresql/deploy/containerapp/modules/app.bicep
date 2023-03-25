@description('Specifies the name of the Container App.')
param name string

@description('Specifies the location to deploy to.')
param location string

@description('Specifies the name of Azure Container Apps environment to deploy to.')
param environmentId string

@description('Specifies the container image.')
param image string

@description('Specifies the database name to use.')
param database string

@description('Specifies the secrets used by the application.')
@secure()
param secrets object

resource containerApp 'Microsoft.App/containerApps@2022-10-01' = {
  name: name
  location: location
  properties: {
    managedEnvironmentId: environmentId
    configuration: {
      ingress: {
        external: true
        targetPort: 8080
      }
      dapr: {
        enabled: false
      }
      secrets: [
        {
          name: 'postgres-host'
          value: secrets.postgres.host
        }
        {
          name: 'postgres-username'
          value: secrets.postgres.username
        }
        {
          name: 'postgres-password'
          value: secrets.postgres.password
        }
        {
          name: 'appinsights-connectionstring'
          value: secrets.appinsights.connectionString
        }
      ]
    }
    template: {
      containers: [
        {
          image: image
          name: name
          env: [
            {
              name: 'POSTGRESQL_HOST'
              secretRef: 'postgres-host'
            }
            {
              name: 'POSTGRESQL_USERNAME'
              secretRef: 'postgres-username'
            }
            {
              name: 'POSTGRESQL_PASSWORD'
              secretRef: 'postgres-password'
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              secretRef: 'appinsights-connectionstring'
            }
            {
              name: 'POSTGRES_DB'
              value: database
            }
          ]
          resources: {
            cpu: json('1.0')
            memory: '2Gi'
          }
          probes: [
            {
              type: 'startup'
              httpGet: {
                scheme: 'HTTP'
                path: '/actuator/health/liveness'
                port: 4004
              }
              failureThreshold: 10
              periodSeconds: 15
            }
            {
              type: 'liveness'
              httpGet: {
                scheme: 'HTTP'
                path: '/actuator/health/liveness'
                port: 4004
              }
            }
            {
              type: 'readiness'
              httpGet: {
                scheme: 'HTTP'
                path: '/actuator/health/readiness'
                port: 4004
              }
              initialDelaySeconds: 15
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 4
        rules: [
          {
            name: 'httpscale'
            http: {
              metadata: {
                concurrentRequests: '100'
              }
            }
          }
        ]
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
