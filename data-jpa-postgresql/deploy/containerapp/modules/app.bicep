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

@description('Specifies the name of the Open Telemetry Collector Container App.')
param collector string

@description('Specifies the secrets used by the application.')
@secure()
param secrets object

var healthCheck = {
  scheme: 'HTTP'
  port: 4004
  path: '/actuator/health'
}

resource containerApp 'Microsoft.App/containerApps@2023-11-02-preview' = {
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
              name: 'POSTGRES_DB'
              value: database
            }
            {
              name: 'OTEL_EXPORTER_OTLP_ENDPOINT'
              value: 'http://${collector}:4318'
            }
            {
              name: 'OTEL_EXPORTER_OTLP_PROTOCOL'
              value: 'http/protobuf'
            }
            {
              name: 'OTEL_TRACES_EXPORTER'
              value: 'otlp'
            }
            {
              name: 'OTEL_METRICS_EXPORTER'
              value: 'otlp'
            }
            {
              name: 'OTEL_LOGS_EXPORTER'
              value: 'console'
            }
            {
              name: 'OTEL_RESOURCE_ATTRIBUTES'
              value: 'service.name=springboot-todo-api,service.version=1.0.0,deployment.environment=dev,datadog.container.tag.geo=emea'
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
                scheme: healthCheck.scheme
                path: '${healthCheck.path}/liveness'
                port: healthCheck.port
              }
              failureThreshold: 10
              periodSeconds: 15
            }
            {
              type: 'liveness'
              httpGet: {
                scheme: healthCheck.scheme
                path: '${healthCheck.path}/liveness'
                port: healthCheck.port
              }
            }
            {
              type: 'readiness'
              httpGet: {
                scheme: healthCheck.scheme
                path: '${healthCheck.path}/readiness'
                port: healthCheck.port
              }
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
