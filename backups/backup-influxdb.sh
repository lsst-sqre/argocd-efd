#!/bin/bash

set -x

instance=$1
shard=$2

[ -z "$instance" ] && echo "Usage: $0 <instance name>" && exit 1


export KUBECONFIG=$HOME/.kube/config-${instance}.yaml

kubectl config get-contexts

date=$(date +%Y-%m-%d)

[ -z "$shard" ] && {
        echo "Full EFD Back up"
        influxd backup -portable -database efd -host 127.0.0.1:8088 $instance-efd-$date.influx
} || {
        echo "EFD Back up for shard $shard"
        influxd backup -portable -database efd -host 127.0.0.1:8088 -shard $shard $instance-efd-s$shard-$date.influx
}
