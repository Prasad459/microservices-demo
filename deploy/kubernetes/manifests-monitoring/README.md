# Minitoring stack manifests

These manifests was generated using the [**Kube-Prometheus**](https://github.com/coreos/kube-prometheus#customizing-kube-prometheus) Operator maintened by [CoreOS](https://github.com/coreos).

The following components will be provisioned by applying these manifests:

 * The Prometheus Operator
 * Prometheus
 * Alertmanager
 * Prometheus node-exporter
 * Prometheus Adapter for Kubernetes Metrics APIs
 * kube-state-metrics
 * Grafana (with custom dashboards for this demo!)

## Applying the pre-built manifests
To apply the pre-built manifests for this demo, just:

```
kubectl apply -f manifests/
kubectl apply -f manifests/ # This command sometimes may need to be done twice (to workaround a race condition).
```

You can access the web consoles as follow:

```
kubectl --namespace monitoring port-forward svc/prometheus-k8s 9090&
kubectl --namespace monitoring port-forward svc/grafana 3000&
kubectl --namespace monitoring port-forward svc/alertmanager-main 9093&
```

Got to http://localhost:9090

## Customizing the monitoring stack components (optional)
If you need to customize something, edit the `grafana-with-custom-dashboards.jsonnet` file.

> Note: you will need some additional tools to manipulate this manifest file. Please follow the instructions from [**Kube-Prometheus**](https://github.com/coreos/kube-prometheus#customizing-kube-prometheus) operator's github repo.

Here are the steps I perfom on my local environment:

> inside the `manifests-monitoring` directory...

```
go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
go get github.com/google/go-jsonnet/cmd/jsonnet
go get github.com/brancz/gojsontoyaml
jb init
jb install github.com/coreos/kube-prometheus/jsonnet/kube-prometheus@release-0.1
./build.sh

```