#!/bin/bash

set -x

export KUBECONFIG=$HOME/.kube/config-summit.yaml

kubectl config get-contexts

read -r -p "Do you want to proceed? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    while true; do kubectl port-forward service/influxdb -n influxdb 8088:8088; echo "Restarting..."; done
fi
