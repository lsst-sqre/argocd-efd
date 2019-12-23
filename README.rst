
argocd-efd
==========
EFD deployment configuration managed by Argo CD

TL;DR
-----

.. list-table::

   * - Summit EFD
     - https://argocd-summit.lsst.codes
   * - Tucson Teststand EFD
     - https://argocd-tucson-teststand.lsst.codes
   * - NCSA Teststand EFD
     - https://argocd-ncsa-teststand.lsst.codes



Bootstrap an EFD deployment
---------------------------

``argocd-efd`` uses the `app of apps pattern <https://argoproj.github.io/argo-cd/operator-manual/cluster-bootstrapping/>`_ to bootstrap a new EFD deployment.

The following will bootstrap an EFD deployment at the ``summit``. It assumes that ``kubectl`` is set to the right context and that `Argo CD is running on the destination cluster <https://sqr-031.lsst.io>`_. Note that we connect to Argo CD on `localhot:8080` because `nginx-ingress` is deployed as part of the ``efd`` app.

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

``argocd-efd`` manages the deployment of the EFD on multiple environments. The possible environments are ``summit``, ``tucson-teststand``, ``ncsa-teststand``, ``ldf``, and ``gke``.


Types of deployment
^^^^^^^^^^^^^^^^^^^

There are two types of deployment, the `source EFD and the aggregator EFD <https://sqr-034.lsst.io/#introduction>`_.

A source EFD is deployed to the  ``summit``, ``tucson-teststand``, and ``ncsa-teststand`` environments, while an aggregator EFD is deployed to the ``ldf`` and ``gke`` environments.


EFD apps
^^^^^^^^

A source EFD has the following apps:

- nginx-ingress
- vaul-secrets-operator
- cp-helm-charts
- influxb-sink
- influxdb
- kapacitor
- telegraf

An aggregator EFD has in addition:

- aggregator
- replicator
- oracle-sink
- parket-sink

Naming convention
^^^^^^^^^^^^^^^^^

The Argo CD parent app, used to bootstrap the deployment is named ``efd`` in each environment.

Configuration values for the apps are named after the environment ``values-<environment>.yaml``.

Finally, service names for the apps follow the convention ``<app>-<environment>-efd.lsst.codes``, for example, `chronograf-summit-efd.lsst.codes <https://chronograf-summit-efd.lsst.codes>`_.
