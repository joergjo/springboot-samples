import { collectorConfig } from './collector-config.bicep'

@description('Specifies the name of the OpenTelemetry Collector Container App.')
param name string = 'otel-collector'

@description('Specifies the location to deploy to.')
param location string

@description('Specifies the name of Azure Container Apps environment to deploy to.')
param environmentId string

@description('Specifies the OpenTelemetry Collector container image.')
param image string = 'otel/opentelemetry-collector-contrib:latest'

@description('Specifies the Datadog site.')
param ddSite string = 'datadoghq.com'

@description('Specifies the Datadog API Key.')
@secure()
param ddApiKey string

var healthCheck = {
  scheme: 'HTTP'
  port: 13133
  path: '/'
}

// The OpenTemeletry Collector uses 
// - port 4318 for its OTLP HTTP endpoint
// - port 8888 for its own Prometheus metrics endpoint
// - port 13133 for health checks (liveness and readiness)
// Port 4318 and 8888 must be exposed. 
resource containerApp 'Microsoft.App/containerApps@2023-11-02-preview' = {
  name: name
  location: location
  properties: {
    managedEnvironmentId: environmentId
    configuration: {
      ingress: {
        external: false
        exposedPort: 4318
        targetPort: 4318
        additionalPortMappings: [
          {
            external: false
            exposedPort: 8888
            targetPort: 8888
          }
        ] 
        transport: 'tcp'
      }
      dapr: {
        enabled: false
      }
      secrets: [
        {
          name: 'dd-api-key'
          value: ddApiKey
        }
      ]
    }
    template: {
      containers: [
        {
          image: image
          name: name
          args: [
            '--config=env:COLLECTOR_CONFIG'
          ]
          env: [
            {
              name: 'COLLECTOR_CONFIG'
              value: collectorConfig
            }
            {
              name: 'DD_SITE'
              value: ddSite
            }
            {
              name: 'DD_API_KEY'
              secretRef: 'dd-api-key'
            }
          ]
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          probes: [
            {
              type: 'liveness'
              httpGet: {
                scheme: healthCheck.scheme
                path: healthCheck.path
                port: healthCheck.port
              }
            }
            {
              type: 'readiness'
              httpGet: {
                scheme: healthCheck.scheme
                path: healthCheck.path
                port: healthCheck.port
              }
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}

output appName string = containerApp.name
output fqdn string = containerApp.properties.configuration.ingress.fqdn
