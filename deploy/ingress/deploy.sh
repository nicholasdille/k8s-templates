#!/bin/bash
set -o errexit

if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 <cloudflare-key>"
    exit 1
fi
CF_API_KEY=$1

if ! docker version 2>&1; then
    echo "Error: Docker not running"
    exit 1
fi

kind create cluster --name test --config deploy/ingress/kind.yaml

kubectl create namespace kapp
export KAPP_NAMESPACE=kapp

ip address show dev eth0 | grep " inet " | tr -s ' ' | cut -d' ' -f3 | cut -d'/' -f1 \
| xargs -I{} kubectl label node test-control-plane dille.io/public-ip={}

./bin/ytt \
    -f app/traefik/base/ \
    -f app/traefik/kind-affinity/ \
    -f app/traefik/external-dns/ \
    -f deploy/ingress/values.yaml \
    -v cloudflare.key=${CF_API_KEY} \
| ./bin/kapp deploy --app traefik --file - --yes

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
    -f app/nginx/ \
    -f overlay/namespace/ \
    -v namespace=nginx \
    -f deploy/ingress/values.yaml \
| ./bin/kapp deploy --app nginx --file - --yes