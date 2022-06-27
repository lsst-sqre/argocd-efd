#!/bin/bash

set -x

export KUBECONFIG=$HOME/.kube/config-summit.yaml

kubectl config get-contexts

while true; do kubectl port-forward service/influxdb -n influxdb 8088:8088; echo "Restarting..."; done
