#!/bin/bash

set -x

instance=$1

[ -z "$instance" ] && echo "Usage: $0 <instance name>" && exit 1

export KUBECONFIG=$HOME/.kube/config-${instance}.yaml

kubectl config get-contexts

pod=$(kubectl get pods -n kapacitor | grep kapacitor | cut -d " " -f1)

echo "Found pod at $instance instance: $pod"

date=$(date +%Y-%m-%d)

mkdir -p $instance-kapacitor-$date

echo "Backing up kapacitor database..."
kubectl cp -n kapacitor $pod:/var/lib/kapacitor/kapacitor.db $instance-kapacitor-$date/kapacitor.db
