#!/bin/bash

set -x

instance=$1

[ -z "$instance" ] && echo "Usage: $0 <instance name>" && exit 1

export KUBECONFIG=$HOME/.kube/config-${instance}.yaml

kubectl config get-contexts

pod=$(kubectl get pods -n chronograf | grep chronograf | cut -d " " -f1)

echo "Found pod at $instance instance: $pod"

date=$(date +%Y-%m-%d)

mkdir -p $instance-chronograf-$date

echo "Backing up Chronograf database (dashboards and users)"
kubectl cp -n chronograf $pod:/var/lib/chronograf/chronograf-v1.db $instance-chronograf-$date/chronograf-v1.db

echo "Backing up Chronograf database in InfluxDB (annotations and alert history)"
influxd backup -portable -database chronograf -host 127.0.0.1:8088 $instance-chronograf-$date.influx
