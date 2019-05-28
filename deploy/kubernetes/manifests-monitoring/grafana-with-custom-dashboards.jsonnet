// Import KSonnet library
local k = import "ksonnet.beta.3/k.libsonnet";
local kp = 
  (import 'kube-prometheus/kube-prometheus.libsonnet') + 
  (import 'kube-prometheus/kube-prometheus-node-ports.libsonnet') +
  {
    _config+:: {
      namespace: 'monitoring',
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
  };

  { ['00namespace-' + name]: kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus) } +
  { ['0prometheus-operator-' + name]: kp.prometheusOperator[name] for name in std.objectFields(kp.prometheusOperator) } +
  { ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
  { ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
  { ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
  { ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
  { ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) }
