# How to deploy an Ingress Controller

Prerequisites: cloudflare token

traefik with external-dns:

```bash
./bin/ytt -f app/traefik/base/ -f app/traefik/external-dns/ -f deploy/ingress/values.yaml -v cloudflare.key=<your-cloudflare-key> | kapp deploy --app traefik --file -
```

cert-manager:

```bash
ytt -f app/cert-manager/base/ -f deploy/ingress/values.yaml | kapp deploy --app cert-manager --file -
```

cert-manager issuer:

```bash
ytt -f app/cert-manager/letsencrypt-cloudflare/ -f deploy/ingress/values.yaml -v cloudflare.key=<your-cloudflare-key> | kapp deploy --app cert-manager-issuer --file -
```

external-dns:

```bash
ytt -f app/external-dns/ -f deploy/ingress/values.yaml -v cloudflare.key=<your-cloudflare-key> | kapp deploy --app external-dns --file -
```

Example app:

```bash
ytt -f app/nginx/ -f overlay/namespace/ -v namespace=nginx -f deploy/ingress/ | kapp deploy --app nginx --file -
```
