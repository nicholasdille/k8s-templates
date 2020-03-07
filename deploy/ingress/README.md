# How to deploy an Ingress Controller

## Prepare

XXX

1. XXX VM
1. XXX deploy kind cluster: `kind create cluster --name test --config kind.yaml`
1. Create namespace: `kubectl create namespace kapp`
1. Force `kapp` to store state in new namespace: `export KAPP_NAMESPACE=kapp`
1. Determine host IP from `ip address`
1. Add node label with the IP address: `kubectl label nodes test-control-plane dille.io/public-ip=IP_ADDRESS`

## Install

Prerequisites: cloudflare token

cert-manager:

```bash
./bin/ytt -f app/cert-manager/base/ -f deploy/ingress/values.yaml | ./bin/kapp deploy --app cert-manager --file -
```

cert-manager issuer:

```bash
./bin/ytt -f app/cert-manager/letsencrypt-cloudflare/ -f deploy/ingress/values.yaml -v cloudflare.key=<your-cloudflare-key> | ./bin/kapp deploy --app cert-manager-issuer --file -
```

external-dns:

```bash
./bin/ytt -f app/external-dns/ -f deploy/ingress/values.yaml -v cloudflare.key=<your-cloudflare-key> | ./bin/kapp deploy --app external-dns --file -
```

traefik with external-dns:

```bash
./bin/ytt -f app/traefik/base/ -f app/traefik/kind-affinity/ -f app/traefik/external-dns/ -f deploy/ingress/values.yaml -v cloudflare.key=<your-cloudflare-key> | ./bin/kapp deploy --app traefik --file -
```

Example app:

```bash
./bin/ytt -f app/nginx/ -f overlay/namespace/ -v namespace=nginx -f deploy/ingress/values.yaml | ./bin/kapp deploy --app nginx --file -
```

## Test

XXX insecure

```bash
curl --silent --fail --resolve nginx.dille.io:80:127.0.0.1 http://nginx.dille.io
```

XXX secure with staging CA

```bash
curl --silent --fail --insecure --resolve nginx.dille.io:443:127.0.0.1 https://nginx.dille.io
```

XXX secure

```bash
curl --silent --fail --resolve nginx.dille.io:443:127.0.0.1 https://nginx.dille.io
```
