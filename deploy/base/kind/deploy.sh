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
if ! make --version 2>&1; then
    echo "Error: make not found"
    exit 1
fi

make kind ytt kapp

IP=$(ip address show dev ${INTERFACE} | grep " inet " | tr -s ' ' | cut -d' ' -f3 | cut -d'/' -f1)
if [[ -z "${IP}" ]]; then
    echo "Error: Unable to determine IP address for interface ${INTERFACE}"
    exit 1
fi

if ! kind get clusters | grep -q demo; then
    ./bin/ytt \
        -f deploy/base/kind/kind.yaml \
        -f app/traefik/init-dns/values.yaml \
        -f deploy/base/values.yaml \
        -v kind.master.ip=${IP} \
    | ./bin/kind create cluster --name demo --config -
fi

./bin/kubectl -n kube-system get configmaps kube-proxy -o yaml | \
    sed 's/metricsBindAddress: 127.0.0.1:10249/metricsBindAddress: 0.0.0.0:10249/' | \
    sed 's/metricsBindAddress: ""/metricsBindAddress: 0.0.0.0:10249/' | \
    ./bin/kubectl apply -f -
./bin/kubectl -n kube-system get pod -l k8s-app=kube-proxy -o name | xargs ./bin/kubectl -n kube-system delete

./bin/kubectl apply -f deploy/namespace.yaml
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
    -f app/prometheus/operator/values.yaml \
| ./bin/kapp deploy --app node-exporter --file - --yes

./bin/ytt \
    -f app/kube-state-metrics/ \
| ./bin/kapp deploy --app kube-state-metrics --file - --yes

./bin/ytt \
    -f app/loki/ \
| ./bin/kapp deploy --app loki --file - --yes

./bin/ytt \
    -f app/grafana/ \
    -f deploy/base/values.yaml \
    -v grafana.admin.password=$(openssl rand -hex 16) \
    -v grafana.database.password=$(openssl rand -hex 16) \
| ./bin/kapp deploy --app grafana --file - --yes

OPENLDAP_ADMIN_PASSWORD=$(openssl rand -hex 32)
GANGWAY_SESSION_SECRET=$(openssl rand -base64 32)
GANGWAY_CLIENT_SECRET=$(openssl rand -hex 32)
./bin/ytt \
    -f app/auth/ \
    -f deploy/auth/values.yaml \
    -v openldap.password.admin=${OPENLDAP_ADMIN_PASSWORD} \
    -v gangway.session.secret=${GANGWAY_SESSION_SECRET} \
    -v gangway.client.secret=${GANGWAY_CLIENT_SECRET} \
| ./bin/kapp deploy --app auth --file - --yes
