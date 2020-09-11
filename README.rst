
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
   * - Base
     - https://kueyen.lsst.codes/argo-cd
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

For that, a Kubernetes secret containing the read `VAULT_TOKEN` and the `VAULT_TOKEN_LEASE_DURATION` (in seconds) needs to be created. The read VAULT_TOKEN for the specific cluster can be found on SQuaRE's 1Password.


.. code-block::

  export VAULT_TOKEN=<vault token>
  export VAULT_TOKEN_LEASE_DURATION=<vault token lease duration>

  kubectl create secret generic vault-secrets-operator --from-literal=VAULT_TOKEN=$VAULT_TOKEN --from-literal=VAULT_TOKEN_LEASE_DURATION=$VAULT_TOKEN_LEASE_DURATION --namespace vault-secrets-operator


Secrets are created manually on Vault, use a write `VAULT_TOKEN` to create these:

.. code-block::

  export VAULT_ADDR=https://vault.lsst.codes
  export VAULT_TOKEN=<vault token>
  export VAULT_PATH=<vault path>

InfluxDB credentials
^^^^^^^^^^^^^^^^^^^^

.. code-block::

  vault kv put $VAULT_PATH/influxdb-auth influxdb-user=admin influxdb-password=

TLS certs
^^^^^^^^^

Make sure you pick the chain certificate for `tls.crt`.

.. code-block::

  vault kv put $VAULT_PATH/tls-certs tls.crt=@tls.crt tls.key=@/tls.key


Chronograf GitHub OAuth
^^^^^^^^^^^^^^^^^^^^^^^

.. code-block::

  export TOKEN_SECRET=$(openssl rand -base64 256 | tr -d '\n')
  export GITHUB_CLIENT_ID=
  export GITHUB_CLIENT_SECRET=

  vault kv put  $VAULT_PATH/chronograf-oauth  token_secret=$TOKEN_SECRET gh_client_id=$GITHUB_CLIENT_ID  gh_client_secret=$GITHUB_CLIENT_SECRET gh_orgs=lsst-sqre


Control center
^^^^^^^^^^^^^^

.. code-block::

  export COOKIE_SECRET=$(openssl rand -base64 256 | tr -d '\n')
  export GITHUB_CLIENT_ID=
  export GITHUB_CLIENT_SECRET=

  vault kv put $VAULT_PATH/control-center-oauth  client-id=$GITHUB_CLIENT_ID client-secret=$GITHUB_CLIENT_SECRET  cookie-secret=$COOKIE_SECRET


Environments
------------

``argocd-efd`` manages the deployment of the EFD on multiple environments. The possible environments are ``summit``, ``base``, ``tucson-teststand``, ``ncsa-teststand``,``ncsa-int``, ``ncsa-stable`` and ``sandbox``. Configuration values for the apps are named after the environment ``values-<environment>.yaml``.



EFD apps
^^^^^^^^

An EFD instance has the following applications:

- Confluent Kafka: Kafka, Zookeeper, kafka Connect, Schema Registry and Control Center
- InfluxDB: Time-series database
- Chronograf: Time-series visualization
- Kapacitor: Time-series monitoring and alerting
- Lenses InfluxDB Sink Connector
- Confluent Replicator Connector (experimental)
- Telegraf Daemon Set: Kubernetes cluster monitoring (work in progress)
- Aggregator (work in progress)
- Oracle Sink Connector (work in progress)
- Parquet Sink Connector (work in progress)


Service names
^^^^^^^^^^^^^

Service names for the apps follow the convention (when possible) ``<app>-<environment>-efd.lsst.codes``, for example, `chronograf-summit-efd.lsst.codes <https://chronograf-summit-efd.lsst.codes>`_.

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
  create_dns_record.sh control-center $ENV-efd $LB_IP
  create_dns_record.sh kafka-0 $ENV-efd $LB_IP
