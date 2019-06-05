# Installing sock-shop on Kubernetes

## Spin up a local Kubernetes Cluster using Minikube (optional)

 * Certify you have Virtualbox (or other virtualization platform supported by minikube) installed.
 * Download minikube bits and start a new cluster instance:

```
minikube start \
 --bootstrapper=kubeadm \
 --disk-size 20GB \
 --memory 8046 \
 --cpus 4 \
 --bootstrapper=kubeadm \
 --extra-config=kubelet.authentication-token-webhook=true \
 --extra-config=kubelet.authorization-mode=Webhook \
 --extra-config=scheduler.address=0.0.0.0 \
 --extra-config=controller-manager.address=0.0.0.0
 ```


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

The manifests for the monitoring are available in [manifests-monitoring](./manifests-monitoring) directory.

Create the Monitoring Stack resources:
```
kubectl create -f manifests-monitoring/manifests
kubectl apply -f manifests-monitoring/manifests
```

### What's Included?

* Sock-shop grafana dashboards
* Alertmanager
* Prometheus with config to scrape all k8s pods, connected to local alertmanager.

### Ports

 * Prometheus is exposed on `30900`;
 * Grafana will be exposed on the NodePort `30902`;
 * AlertManager will be exposed on the NodePort `30903`;

If running on a real cluster, the easiest way to connect to these ports is by port forwarding:
```
kubectl port-forward svc/grafana 3000:30900 -n monitoring
```

Where all the pertinent information should be entered. In this example Grafana will be available on `http://localhost:30900`.

If on Minikube, you can connect via the VM IP address and the NodePort: `http://$(minikube ip):<NodePort>`

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