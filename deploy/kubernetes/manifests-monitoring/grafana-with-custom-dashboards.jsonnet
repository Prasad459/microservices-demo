// Import KSonnet library
// local k = import "ksonnet.beta.3/k.libsonnet";
local kp = 
  (import 'kube-prometheus/kube-prometheus.libsonnet') + 
  (import 'kube-prometheus/kube-prometheus-node-ports.libsonnet') +
  {
    _config+:: {
      namespace: 'monitoring',
      prometheus+:: {
          namespaces+: ['sock-shop', 'jaeger'],
      },
      alertmanager+: {
          config: importstr 'alertmanager-config.yaml',
      },
      grafana+:: {
        config: {  // http://docs.grafana.org/installation/configuration/
          sections: {
            // Do not require grafana users to login/authenticate
            'auth.anonymous': { enabled: true },
          },
        },
      },
    },
    grafanaDashboards+:: {
      'sock-shop-analytics-dashboard.json': (import 'sock-shop-analytics-dashboard.json'),
      'sock-shop-performance-dashboard.json': (import 'sock-shop-performance-dashboard.json'),
      'sock-shop-resources-dashboard.json': (import 'sock-shop-resources-dashboard.json')
    },
    prometheus+::{
      serviceMonitorAnyNamespace:
      {
        apiVersion: 'monitoring.coreos.com/v1',
        kind: 'ServiceMonitor',
        metadata: {
          name: 'scrap-any',
          namespace: $._config.namespace,
          labels: {
            'k8s-app': 'scrap-any',
          },
        },
        spec: {
          jobLabel: 'scrap-any',
          endpoints: [
            {
              port: 'http',
              interval: '30s',
            },
            {
              port: 'http-metrics',
              interval: '30s',
            },
            {
              port: 'exporter',
              interval: '30s',
            },
            {
              targetPort: 80,
              interval: '30s',
            },
            {
              targetPort: 8079,
              interval: '30s',
            },
          ],
          selector: {
            matchLabels: {
              'prometheus-scrap': 'yes',
              'name': '*',
            },
          },
          namespaceSelector: {
            any: true,
          },
        },
      },
      serviceMonitorSockShop:
      {
        apiVersion: 'monitoring.coreos.com/v1',
        kind: 'ServiceMonitor',
        metadata: {
          name: 'sock-shop',
          namespace: $._config.namespace,
          labels: {
            'k8s-app': 'sock-shop',
          },
        },
        spec: {
          jobLabel: 'sock-shop',
          endpoints: [
            {
              port: 'http',
              interval: '30s',
            },
            {
              port: 'http-metrics',
              interval: '30s',
            },
            {
              port: 'exporter',
              interval: '30s',
            },
            {
              targetPort: 80,
              interval: '30s',
            },
            {
              targetPort: 8079,
              interval: '30s',
            },
          ],
          selector: {
            matchLabels: {
              'prometheus-scrap': 'yes',
            },
          },
          namespaceSelector: {
            matchNames: [
              'sock-shop',
            ],
          },
        },
      },
    },
    prometheusAlerts+:: {
      groups+: [
        {
          name: 'sockshop-group',
          rules: [
            {
              alert: 'Slack',
              expr: 'rate(request_duration_seconds_count{status_code="500"}[5m]) > 1',
              "for": "5m",
              labels: {
                severity: 'slack',
              },
              annotations: {
                summary: 'High HTTP 500 error rates',
                description: 'Rate of HTTP 500 errors per 5 minutes: {{ $value }}',
              },
            },
          ],
        },
      ],
    },
  };

  { ['00namespace-' + name]: kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus) } +
  { ['0prometheus-operator-' + name]: kp.prometheusOperator[name] for name in std.objectFields(kp.prometheusOperator) } +
  { ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
  { ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
  { ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
  { ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
  { ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) }
