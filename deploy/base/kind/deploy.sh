#!/bin/bash
set -o errexit

if [[ "$#" -ne 2 ]]; then
    echo "Usage: $0 <interface> <cloudflare-key>"
    exit 1
fi
INTERFACE=$1
CF_API_KEY=$2

if ! docker version 2>&1; then
    echo "Error: Docker not running"
    exit 1
fi

make kind ytt kapp

./bin/kind create cluster --config deploy/base/kind/kind.yaml

kubectl create namespace kapp
export KAPP_NAMESPACE=kapp

ip address show dev ${INTERFACE} | grep " inet " | tr -s ' ' | cut -d' ' -f3 | cut -d'/' -f1 \
| xargs -I{} kubectl label node kind-control-plane dille.io/public-ip={}

kubectl -n kube-system get configmaps kube-proxy -o yaml | \
    sed 's/metricsBindAddress: 127.0.0.1:10249/metricsBindAddress: 0.0.0.0:10249/' | \
    sed 's/metricsBindAddress: ""/metricsBindAddress: 0.0.0.0:10249/' | \
    kubectl apply -f -

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
    -f app/traefik/init-dns/ \
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