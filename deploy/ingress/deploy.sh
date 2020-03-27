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

kind create cluster --config deploy/ingress/kind.yaml

kubectl create namespace kapp
export KAPP_NAMESPACE=kapp

ip address show dev ${INTERFACE} | grep " inet " | tr -s ' ' | cut -d' ' -f3 | cut -d'/' -f1 \
| xargs -I{} kubectl label node kind-control-plane dille.io/public-ip={}

./bin/ytt \
    -f app/cert-manager/base/ \
    -f deploy/ingress/values.yaml \
| ./bin/kapp deploy --app cert-manager --file - --yes

./bin/ytt \
    -f app/cert-manager/letsencrypt-cloudflare/ \
    -f deploy/ingress/values.yaml \
    -v cloudflare.key=${CF_API_KEY} \
| ./bin/kapp deploy --app cert-manager-issuer --file - --yes

./bin/ytt \
    -f app/external-dns/ \
    -f deploy/ingress/values.yaml \
    -v cloudflare.key=${CF_API_KEY} \
| ./bin/kapp deploy --app external-dns --file - --yes

./bin/ytt \
    -f app/traefik/base/ \
    -f app/traefik/kind-affinity/ \
    -f app/traefik/init-dns/ \
    -f deploy/ingress/values.yaml \
    -v cloudflare.key=${CF_API_KEY} \
| ./bin/kapp deploy --app traefik --file - --yes
