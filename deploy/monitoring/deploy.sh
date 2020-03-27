#!/bin/bash
set -o errexit

export KAPP_NAMESPACE=kapp

./bin/ytt \
    -f app/prometheus/operator/ \
| ./bin/kapp deploy --app prometheus-operator --file - --yes

sleep 10

./bin/ytt \
    -f app/prometheus/instance/ \
| ./bin/kapp deploy --app prometheus --file - --yes

./bin/ytt \
    -f app/prometheus/servicemonitors/ \
    -f app/prometheus/operator/values.yaml \
| ./bin/kapp deploy --app servicemonitors --file - --yes

./bin/ytt \
    -f app/prometheus/node-exporter/ \
| ./bin/kapp deploy --app node-exporter --file - --yes

./bin/ytt \
    -f app/kube-state-metrics/ \
| ./bin/kapp deploy --app kube-state-metrics --file - --yes

./bin/ytt \
    -f app/grafana/ \
    -f deploy/monitoring/values.yaml \
| ./bin/kapp deploy --app grafana --file - --yes
