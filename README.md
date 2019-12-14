# argocd-efd
EFD deployment configuration managed by Argo CD

## TL;DR
### Bootstrap an EFD deployment

`argocd-efd` uses the [app of apps pattern](https://argoproj.github.io/argo-cd/operator-manual/cluster-bootstrapping/) to bootstrap a new EFD deployment.

This command will create and sync an EFD deployment on GKE, where `gke-efd` is the Argo CD parent app. It assumes that Argo CD is running on the destination cluster.

```
argocd app create gke-efd --dest-namespace argocd --dest-server https://kubernetes.default.svc --repo https://github.com/lsst-sqre/argocd-efd.git --path apps/gke-efd
argocd app sync gke-efd
```

### Secrets

The EFD application deploys the `vault-secrets-operator` which is configured to retrieve the right secrets from https://vault.lsst.codes. However, a Kubernetes secret containing the `VAULT_TOKEN` and the `VAULT_TOKEN_LEASE_DURATION` (in seconds) still needs to be created manually.


```
export VAULT_TOKEN=
export VAULT_TOKEN_LEASE_DURATION=

$ kubectl create secret generic vault-secrets-operator --from-literal=VAULT_TOKEN=$VAULT_TOKEN --from-literal=VAULT_TOKEN_LEASE_DURATION=$VAULT_TOKEN_LEASE_DURATION --namespace vault-secrets-operator
```


## Environments

`argocd-efd` manages the deployment of the EFD on multiple environments. The possible environments are `summit`, `tucson-teststand`, `ncsa-teststand`, `ldf`, and `gke`.


## Types of deployment

There are two types of deployment, the [source EFD and the aggregator EFD](https://sqr-034.lsst.io/#introduction).

The source EFD is deployed to the  `summit`, `tucson-teststand`, and to the `ncsa-teststand` environments, while the aggregator EFD is deployed to the `ldf` and `gke` environments.

### EFD apps

A source EFD has the following apps:

- nginx-ingress
- vaul-secrets-operator
- cp-helm-charts
- influxb-sink
- influxdb
- kapacitor
- chronograf
- grafana
- prometheus

An aggregator EFD has in addition:

- replicator
- oracle-sink
- parket-sink
- aggregator

## Naming convention

The Argo CD parent app, used to bootstrap an EFD deployment, is named after the environment `<environment>-efd`, for example, `summit-efd`.

Configuration values for the apps are also named after the environment `values-<environment>.yaml`.

Finally, service names for the apps follow `<app>-<environment>-efd.lsst.codes`, for example, `chronograf-summit-efd.lsst.codes`.
