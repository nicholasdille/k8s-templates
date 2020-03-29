#!/bin/bash
set -o errexit

if [[ "$#" -ne 2 ]]; then
    echo "Usage: $0 <cloudflare-key>"
    exit 1
fi
INTERFACE=$1
CF_API_KEY=$2

if ! docker version 2>&1; then
    echo "Error: Docker not running"
    exit 1
fi

make kind ytt kapp

./bin/kubectl -n kube-system get configmaps kube-proxy -o yaml | \
    sed 's/metricsBindAddress: 127.0.0.1:10249/metricsBindAddress: 0.0.0.0:10249/' | \
    sed 's/metricsBindAddress: ""/metricsBindAddress: 0.0.0.0:10249/' | \
    ./bin/kubectl apply -f -
./bin/kubectl -n kube-system get pod -l k8s-app=kube-proxy -o name | xargs ./bin/kubectl -n kube-system delete

./bin/kubectl create namespace kapp
export KAPP_NAMESPACE=kapp

./bin/kubectl apply -f app/prometheus/operator/crd.yaml

./bin/ytt \
    -f app/cert-manager/base/ \
    -f deploy/base/values.yaml \
| ./bin/kapp deploy --app cert-manager --file - --yes

./bin/ytt \
    -f app/cert-manager/letsencrypt-cloudflare/ \
    -f deploy/base/values.yaml \
    -v cloudflare.key=${CF_API_KEY} \
| ./bin/kapp deploy --app cert-manager-issuer --file - --yes

./bin/ytt \
    -f app/external-dns/ \
    -f deploy/base/values.yaml \
    -v cloudflare.key=${CF_API_KEY} \
| ./bin/kapp deploy --app external-dns --file - --yes

./bin/ytt \
    -f app/traefik/base/ \
    -f app/traefik/kind-affinity/ \
    -f app/traefik/external-dns/ \
    -f deploy/base/values.yaml \
    -v cloudflare.key=${CF_API_KEY} \
| ./bin/kapp deploy --app traefik --file - --yes

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
    -f deploy/base/values.yaml \
| ./bin/kapp deploy --app grafana --file - --yes
