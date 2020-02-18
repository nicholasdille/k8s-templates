# App for Traefik

XXX base

XXX external-dns

XXX init-dns

## Usage

Apply base:

```bash
ytt -f app/traefik/base/
```

Apply base with automatically updated DNS record from host IP address:

```bash
ytt -f app/traefik/base/ -f app/traefik/external-dns/
```

Apply base with autoamtically updated DNS record from host label:

```bash
ytt -f app/traefik/base/ -f app/traefik/init-dns/
```

## Variables

- `XXX`
- `dashboard.htpasswd` - generate using `htpasswd -nb admin password | sed -e s/\\$/\\$\\$/g`

## Creating an ingress

XXX

```yaml
---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: my-service-http
  namespace: my-service
spec:
  entryPoints:
    - http
  routes:
    - match: Host(`my-service.someone.io`)
      kind: Rule
      priority: 12
      services:
      - name: my-service
        port: 80
        strategy: RoundRobin
---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: my-service-https
  namespace: my-service
spec:
  entryPoints:
    - https
  routes:
    - match: Host(`my-service.someone.io`)
      kind: Rule
      priority: 12
      services:
      - name: my-service
        port: 80
        strategy: RoundRobin
  tls:
    secretName: certificate-my-service
```
