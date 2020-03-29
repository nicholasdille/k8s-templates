# App for Traefik

The deployment of traefik is located in the subdirectory `base/`.

Multiple options are available to choose from:
- `external-dns`: The DNS record for the load balancer served by traefik is updated from the node IP using a headless service which is deployed by `base`
- `init-dns`: The DNS record for the load balancer served by traefik is updated by an init container using a node label containing the public IP address
- `kind-affinity`: Forced the deployment of traefik to be scheduled in a specific node to match the port publishings in kind

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

Apply base with affinity for kind where port publishing are only available on a specific host:

```bash
ytt -f app/traefik/base/ -f app/traefik/kind-affinity/
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
