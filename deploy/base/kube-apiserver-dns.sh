#!/bin/bash

kubectl get nodes -l node-role.kubernetes.io/master= -o name \
| cut -d/ -f2 \
| while read NODE; do
    IP=$(\
        kubectl get node ${NODE} -o json \
        | jq -r '.status.addresses[] | select(.type == "InternalIP") | .address' \
        ); \
    ./bin/ytt \
        -f deploy/base/kube-apiserver-dns-values.yaml \
        -f deploy/base/kube-apiserver-dns.yaml \
        -f deploy/base/values.yaml \
        -v name=${NODE} \
        -v ip=${IP} \
    | ./bin/kapp deploy --app kube-apiserver-dns-${NODE} --file - --yes; \
done