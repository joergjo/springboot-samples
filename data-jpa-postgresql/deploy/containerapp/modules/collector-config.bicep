@export()
var collectorConfig = '''
receivers:
  otlp:
    protocols:
      http:

processors:
  batch:
    send_batch_max_size: 1000
    send_batch_size: 100
    timeout: 10s

connectors:
    datadog/connector:

exporters:
  datadog/exporter:
    api:
      key: ${env:DD_API_KEY}
      site: ${env:DD_SITE}
    metrics:
      resource_attributes_as_tags: true

extensions:
  health_check:

service:
  telemetry:
    logs:
      level: debug
  extensions: [health_check]
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [datadog/connector, datadog/exporter]
    metrics:
      receivers: [datadog/connector, otlp] 
      processors: [batch]
      exporters: [datadog/exporter]
'''
