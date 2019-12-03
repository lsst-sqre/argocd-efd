# argocd-efd
EFD deployment configuration managed by Argo CD


## Bootstrap an EFD deployment

`argocd-efd` uses the [app of apps pattern](https://argoproj.github.io/argo-cd/operator-manual/cluster-bootstrapping/) to bootstrap a new EFD deployment.

This command will create and sync an EFD deployment on GKE, where `gke-efd` is the parent app. It assummes Argo CD is running on the destination cluster. 

```
argocd app create gke-efd --dest-namespace argocd --dest-server https://kubernetes.default.svc --repo https://github.com/lsst-sqre/argocd-efd.git --path apps/gke-efd
argocd app sync gke-efd
```

## Secrets

The EFD application deploys the `vault-secrets-operator` which is configured to retrieve the right secrets from https://vault.lsst.codes. However, the secret containing the `VAULT_TOKEN` and the `VAULT_TOKEN_LEASE_DURATION` (in seconds) must be created manually.
 
```
export VAULT_TOKEN=
export VAULT_TOKEN_LEASE_DURATION=

cd apps/vault-secrets-operator/vault
./make_vault_token_secret.sh | kubectl apply -f -
```
