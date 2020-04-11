#!/bin/bash

./bin/kubectl -n kube-system get configmaps kube-proxy -o yaml | \
    sed 's/metricsBindAddress: 127.0.0.1:10249/metricsBindAddress: 0.0.0.0:10249/' | \
    sed 's/metricsBindAddress: ""/metricsBindAddress: 0.0.0.0:10249/' | \
    ./bin/kubectl apply -f -
./bin/kubectl -n kube-system get pod -l k8s-app=kube-proxy -o name | xargs ./bin/kubectl -n kube-system delete