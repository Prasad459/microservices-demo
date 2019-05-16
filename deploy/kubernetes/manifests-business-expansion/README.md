# Busisness expansion use case

## Use Case
This demo show how we can incorporate a new product offering into our existing SockShop e-Commerce application without impacting the Business Operation.

Leveraging the capabilities of the Microservices approach and the Kubernetes Platform we can easily deploy new services and upgrade exiting ones with no service interruption.

## New architectural design proposal
To implement this expansion in our e-comerce our architects came up with a new architectural design:

![New Architecture diagram](../../internal-docs/Arch_v2.png "Architecture")

In this design we introduced two new services and updated the `front-end` app.

 1. The [**shoes-catalogue-application**](https://github.com/rafaeltuelho/shoes-catalogue-application) is a __Native__ Java Rest service implemented using **Quarkus.io** and compiled to a native linux binary using **GraalVM.org**
 2. The [**shop-catalogue-aggregator**](https://github.com/rafaeltuelho/shop-catalogue-aggregator) is a Java Rest service implemented using [Apache Camel](https://camel.apache.org/staging/) which is an Open Source Java Integration Framework. This service implements two integration patterns (EIP): [**recipient list**](https://www.enterpriseintegrationpatterns.com/patterns/messaging/RecipientList.html) and [**aggregator**](https://www.enterpriseintegrationpatterns.com/patterns/messaging/Aggregator.html). Using these two patterns the service fetches and aggregates both backend catalogue service response (socks and shoes).
 3. The updated version of [front-end](https://github.com/rafaeltuelho/front-end/tree/shop-aggregator) app points to the new catalogue aggregator service endpoint.

## New services deployment
Given you have the original version of SockShop up & running on top of your Kubernetes cluster, deploy the two new microservices:

```
kubectl create -f deploy/kubernetes/manifests-business-expansion/*.yaml
```

## Upgrade the front-end app
In order to use the new Catalogue Aggregator service we need to upgrade our front-end app. 

First scale your front-end PODs to 3
```
kubectl scale deployments front-end --replicas 3 -n sock-shop && \
kubectl get pods -l front-end -n sock-shop -w
```

Now change the container image version in the front-end `deployment`.

```
kubectl set image deployment/front-end front-end=quay.io/rafaeltuelho/front-end:shop-aggregator -n sock-shop
```

This operation will start a [**Rolling Deployment**](https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/) process into the cluster which will gradually upgrade the `front-end` PODs with a zero down-time approach.

> you can watch the rolling upgrade with:
  ```
  kubectl get pods -l name=front-end -w
  ```
> or accessing the weavescope dashboard.

After a couple of seconds all PODs will be replaced by the new version and you should be able to see some Shoes in the catalogue page.

## Rollback to the original version (only socks)
If you need to rollback to the original (or any older version):

```
kubectl rollout history deployment front-end
kubectl rollout undo deployment front-end --to-revision #revision_number
```

## Clean up
To remove the new services use the following command:

```
kubectl delete -f deploy/kubernetes/manifests-business-expansion/*.yaml
```