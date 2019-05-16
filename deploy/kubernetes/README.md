# Installing sock-shop on Kubernetes

See the [documentation](https://microservices-demo.github.io/deployment/kubernetes-minikube.html) on how to deploy Sock Shop using Minikube.

## Kubernestes manifests

There are 2 sets of manifests for deploying Sock Shop on Kubernetes: one in the [manifests directory](manifests/), and `complete-demo.yaml`. The `complete-demo.yaml` is a single file manifest
made by concatenating all the manifests from the manifests directory, so please regenerate it when changing files in the manifests directory.

## Tracing

All services are configured to report tracing data using the Opentracing standard using jaeger/zipkin protocol.

If you want to query tracing using jaeger deploy jaeger all-in-one manifest:

```
kubectl create -f deploy/kubernetes/manifests-jaeger/jaeger-all-in-one.yaml
```

The Jaeger UI should be available through NodePort at http://$(minikube ip):30003

## Monitoring (Optional)

All monitoring is performed by prometheus. All services expose a `/metrics` endpoint. All services have a Prometheus Histogram called `request_duration_seconds`, which is automatically appended to create the metrics `_count`, `_sum` and `_bucket`.

The manifests for the monitoring are spread across the [manifests-monitoring](./manifests-monitoring) and [manifests-alerting](./manifests-alerting/) directories.

To use them, please run `kubectl create -f <path to directory>`.

### What's Included?

* Sock-shop grafana dashboards
* Alertmanager with 500 alert connected to slack
* Prometheus with config to scrape all k8s pods, connected to local alertmanager.

### Ports

Grafana will be exposed on the NodePort `31300` and Prometheus is exposed on `31090`. If running on a real cluster, the easiest way to connect to these ports is by port forwarding in a ssh command:
```
ssh -i $KEY -L 3000:$NODE_IN_CLUSTER:31300 -L 9090:$NODE_IN_CLUSTER:31090 ubuntu@$BASTION_IP
```
Where all the pertinent information should be entered. Grafana and Prometheus will be available on `http://localhost:3000` or `:9090`.

If on Minikube, you can connect via the VM IP address and the NodePort.

## Wave Scope (optional)

You can use Wave Scope to have a nice graphical view of your cluster.
To deploy it follow the instruction from the offcial docs: https://www.weave.works/docs/scope/latest/installing/#k8s

Or just apply this:

```
kubectl apply -f "https://cloud.weave.works/k8s/scope.yaml?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

In order to access the weave-scope UI from your browser edit the weave-scope-app service:

```
kubectl edit svc weave-scope-app -n weave
```

and change the service type to `NodePort` and assigng the value `30004` to `nodePort`:

```yaml
...
  ports:
  - name: app
    nodePort: 30004
    port: 80
    protocol: TCP
    targetPort: 4040
  type: NodePort
...
```

## Business expansion demo!

There is an extension to this demo showing how you can expand your SockShop e-Commerce to sell Shoes! Check it out [here](manifests-business-expansion/README.md).