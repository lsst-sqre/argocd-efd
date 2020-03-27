
argocd-efd
==========
EFD deployment configuration managed by Argo CD

TL;DR
-----

.. list-table::

   * - **EFD instance**
     - **Argo CD URL**
   * - Summit 
     - https://argocd-summit.lsst.codes
   * - Tucson Test Stand 
     - https://argocd-tucson-teststand.lsst.codes
   * - NCSA Test Stand
     - https://lsst-argocd-nts-efd.ncsa.illinois.edu
   * - LSP Integration 
     - https://lsst-lsp-int.ncsa.illinois.edu/argo-cd
   * - LSP Stable
     - https://lsst-lsp-stable.ncsa.illinois.edu/argo-cd
   * - Sandbox
     - https://argocd-sandbox.lsst.codes



Bootstrap an EFD deployment
---------------------------

``argocd-efd`` uses the `app of apps pattern <https://argoproj.github.io/argo-cd/operator-manual/cluster-bootstrapping/>`_ to bootstrap a new EFD deployment.

The following will bootstrap an EFD deployment at the ``summit``. It assumes that ``kubectl`` is set to the right context and that `Argo CD is running on the destination cluster <https://sqr-031.lsst.io>`_. Note that we connect to Argo CD on `localhot:8080` initially because `nginx-ingress` is deployed as part of the ``efd`` app.

.. code-block::

  kubectl port-forward svc/argocd-server -n argocd 8080:443

  argocd login localhot:8080
  argocd app create efd --dest-namespace argocd --dest-server https://kubernetes.default.svc --repo https://github.com/lsst-sqre/argocd-efd.git --path apps/efd --helm-set env=summit
  argocd app sync efd


Secrets
-------

The EFD application deploys the `vault-secrets-operator <https://github.com/ricoberger/vault-secrets-operator>`_ which is configured to retrieve the right secrets from the `LSST Vault's service <https://vault.lsst.codes>`_.

For that, a Kubernetes secret containing the `VAULT_TOKEN` and the `VAULT_TOKEN_LEASE_DURATION` (in seconds) needs to be created:


.. code-block::

  export VAULT_TOKEN=<vault token>
  export VAULT_TOKEN_LEASE_DURATION=<vault token lease duration>

  kubectl create secret generic vault-secrets-operator --from-literal=VAULT_TOKEN=$VAULT_TOKEN --from-literal=VAULT_TOKEN_LEASE_DURATION=$VAULT_TOKEN_LEASE_DURATION --namespace vault-secrets-operator



Environments
------------

``argocd-efd`` manages the deployment of the EFD on multiple environments. The possible environments are ``summit``, ``tucson-teststand``, ``ncsa-teststand``, and ``sandbox``. Configuration values for the apps are named after the environment ``values-<environment>.yaml``.



EFD apps
^^^^^^^^

A source EFD has the following apps:

- nginx-ingress
- vaul-secrets-operator
- cp-helm-charts
- influxb-sink
- influxdb
- chronograf
- kapacitor
- telegraf (work in progress)
- aggregator (work in progress)
- replicator (work in progress)
- oracle-sink (work in progress)
- parket-sink (work in progress)


Service names
^^^^^^^^^^^^^

Service names for the apps follow the convention ``<app>-<environment>-efd.lsst.codes``, for example, `chronograf-summit-efd.lsst.codes <https://chronograf-summit-efd.lsst.codes>`_.

DNS records are created manually on AWS Route53.

Set your AWS credentials

.. code-block::

  export AWS_ACCESS_KEY_ID=
  export AWS_SECRET_ACCESS_KEY


Get the LoadBalancer Ingress IP address from ``kubectl describe service nginx-ingress-controller -n nginx-ingress``, and then use the following to create the DNS records:

.. code-block::

  export LB_IP=<LoadBalancer Ingress IP address>
  export ENV=<environment>

  cd route53
  create_dns_record.sh influxdb $ENV-efd $LB_IP
  create_dns_record.sh chronograf $ENV-efd $LB_IP
  create_dns_record.sh schema-registry $ENV-efd $LB_IP
  create_dns_record.sh kafka-0 $ENV-efd $LB_IP
