# argocd-efd
EFD deployment configuration managed by Argo CD


## Bootstrap an EFD deployment

`argocd-efd` uses the [app of apps pattern](https://argoproj.github.io/argo-cd/operator-manual/cluster-bootstrapping/) to bootstrap a new EFD deployment.

From the CLI, use the following to create and sync the parent application, e.g., `dev-efd` on the same cluster where Argo CD is running.

```
argocd app create dev-efd --dest-namespace argocd --dest-server https://kubernetes.default.svc --repo https://github.com/lsst-sqre/argocd-efd.git --path apps/dev-efd
argocd app sync dev-efd
```

## Secrets

The EFD application deploys the `vault-secrets-operator` which is configured to retrieve the right secrets from https://vault.lsst.codes. However, the secret containing the VAULT_TOKEN and the VAULT_TOKEN_LEASE_DURATION (in seconds) must be created manually.
 

```
export VAULT_TOKEN=
export VAULT_TOKEN_LEASE_DURATION=

cd apps/vault-secrets-operator/vault
./make_vault_token_secret.sh | kubectl apply -f -
```
