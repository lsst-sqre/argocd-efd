

# Multiple cluster deployment example

In this example, Argo CD manages the deployment of an application to an external cluster.

## Requirements

Argo CD must be installed in both source and destination clusters.

Argo CD CLI is configured to access the source cluster that manages the deployment.

## How it works?

The example uses the "app of apps" pattern.

In the source cluster, the `multicluster-example` parent app is used to bootstrap the deployment of the `nginx-ingress` app to the destination cluster.


## Register a new cluster

Argo CD needs to know about the destination cluster. See the [Argo CD getting started](https://argoproj.github.io/argo-cd/getting_started/#5-register-a-cluster-to-deploy-apps-to-optional) guide on how to register a new cluster to Argo CD.

## Create the multicluster-example app project

When managing multiple clusters, it is a good practice to use projects to safeguard to which cluster an application can be deployed and which cluster resources are allowed to be created.

This creates a new project used for testing our `multicluster-example`. Note that `https://35.238.190.86,argocd` specifies the destination cluster, the one registered above.

```
argocd proj create multicluster-example --description "Used for testing multicluster example"  --dest https://35.238.190.86,argocd --src https://github.com/lsst-sqre/argocd-efd.git
```

Specify which cluster resources are allowed to be created by this project

```
argocd proj allow-cluster-resource multicluster-example '*' '*'
```

NOTE: the project also needs to exist on the destination cluster. You can log in to the destination cluster and use the Argo CD CLI or create the project through the Argo CD UI. The only caveat is to set destination server to `https://35.238.190.86` and destination namespace to "*" if your application creates multiple namespaces in the destination cluster.


## Create the multicluster-example parent app

The following creates the `multicluster-example` parent app in the source cluster. After the synchronization the `nginx-ingress` child app is created in the destination cluster.

```
argocd app create multicluster-example --dest-namespace argocd --dest-server https://35.238.190.86 --repo https://github.com/lsst-sqre/argocd-efd.git --path apps/multicluster-example --project multicluster-example
argocd app sync multicluster-example
```

NOTE: the Application URL to the child app on the destination cluster does not work - it points to the source cluster instead. This looks like a bug or a missing application parameter/configuration in Argo CD.
