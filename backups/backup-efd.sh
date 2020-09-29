#!/bin/bash

set -x

instance=$1

[ -z "$instance" ] && echo "Usage: ./backup-efd.sh <instance name>" && exit 1

pod=$(kubectl get pods -n influxdb | grep influxdb | cut -d " " -f1)

echo "Found pod at $instance instance: $pod"

date=$(date +%Y-%m-%d)

echo "Backing up EFD database..."
kubectl exec -it -n influxdb $pod -- influxd backup -portable -database efd ./$instance-efd-$date.influx
echo "Backing up Chronograf  database..."
kubectl exec -it -n influxdb $pod -- influxd backup -portable -database chronograf ./$instance-chronograf-$date.influx

echo "Copying files..."
kubectl cp -n influxdb $pod:$instance-efd-$date.influx $instance-efd-$date.influx
kubectl cp -n influxdb $pod:$instance-chronograf-$date.influx $instance-chronograf-$date.influx
