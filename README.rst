
NOTE: Deployment configuration in this repo was moved to Phalanx and is now part of Sasquatch.


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
     - https://tucson-teststand.lsst.codes/argo-cd
   * - LSP Integration
     - https://lsst-lsp-int.ncsa.illinois.edu/argo-cd
   * - LSP Stable
     - https://lsst-lsp-stable.ncsa.illinois.edu/argo-cd


Bootstrap an EFD deployment
---------------------------

.. note::

  The EFD deployment is not on `Phalanx <https://github.com/lsst-sqre/phalanx>`_ yet, but you can use the following to deploy the EFD right after deploying RSP with Phalanx.

This repo uses the `app of apps pattern <https://argoproj.github.io/argo-cd/operator-manual/cluster-bootstrapping/>`_ to bootstrap an EFD deployment.

The possible environments to deploy the EFD are ``summit``, ``base``, ``tucson-teststand``, ``ncsa-int``, and ``ncsa-stable``.

Configuration values for each app are in the app's folder, e.g. ``apps/influxdb``, ``apps/chronograf``, etc in a file named after the environment: ``values-<environment>.yaml``.

The following will bootstrap an EFD deployment at the ``tucson-teststand`` environment.
It assumes that ``kubectl`` is set to the right context and that you can login to ``Argo CD`` running on the destination cluster.

.. code-block::

  kubectl port-forward svc/argocd-server -n argocd 8080:443

  argocd login localhot:8080 --username admin --password <argocd admin password>
  argocd app create efd --dest-namespace argocd --dest-server https://kubernetes.default.svc --repo https://github.com/lsst-sqre/argocd-efd.git --path apps/efd --helm-set env=tucson-teststand
  argocd app sync efd


Service names
^^^^^^^^^^^^^

Service names for the apps use the following convention (when possible) ``<app>-<environment>-efd.lsst.codes``, for example, `chronograf-summit-efd.lsst.codes <https://chronograf-summit-efd.lsst.codes>`_.

DNS records are created on AWS Route53 using the ``create_dns_record.sh`` helper script (which works with ``terraform 0.9.11`` on ``amd64``).

Get the LoadBalancer Ingress IP address from ``kubectl describe service nginx-ingress-controller -n nginx-ingress``, and then use the following to create the DNS records, assuming that your AWS credentials are set throught the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables.

.. code-block::

  export LB_IP=<LoadBalancer Ingress IP address>
  export ENV=<environment>

  cd route53
  create_dns_record.sh influxdb $ENV-efd $LB_IP
  create_dns_record.sh chronograf $ENV-efd $LB_IP
  create_dns_record.sh schema-registry $ENV-efd $LB_IP
  create_dns_record.sh kafdrop $ENV-efd $LB_IP


EFD Client
^^^^^^^^^^

The EFD client connects to the EFD InfluxDB instance using the ``efdreader`` user credentials.
See the ``segwarides`` secret for details.

