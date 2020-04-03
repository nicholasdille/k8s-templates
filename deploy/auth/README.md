# Deployment of authentication layer

XXX https://github.com/alexbrand/gangway-dex-tutorial/tree/master/deployment/dex

XXX integration for gitlab.com in GITLAB_APPLICATION_ID and GITLAB_APPLICATION_SECRET

XXX create dex admin password `admin_password`: htpasswd -bnBC 10 "" test123 | tr -d ':\n'

```bash
DEX_ADMIN_PASSWORD=$(htpasswd -bnBC 10 "" test123 | tr -d ':\n')
```

XXX create gangway client secret `client_secret`: openssl rand -hex 32

```bash
GANGWAY_CLIENT_SECRET=$(openssl rand -hex 32)
```

XXX gangway session secret `session_secret`: openssl rand -base64 32

```bash
GANGWAY_SESSION_SECRET=$(openssl rand -base64 32)
```

XXX dex

```bash
./bin/ytt \
    -f app/dex/ \
    -f app/gangway/values.yaml \
    -f app/dex-k8s-authenticator/values.yaml \
    -f deploy/auth/values.yaml \
    -v dex.admin.password=${DEX_ADMIN_PASSWORD} \
    -v dex.gitlabcom.id=${GITLAB_APPLICATION_ID} \
    -v dex.gitlabcom.secret=${GITLAB_APPLICATION_SECRET} \
    -v gangway.client.secret=${GANGWAY_CLIENT_SECRET} \
| ./bin/kapp deploy --app dex --file -
```

XXX dex-k8s-authenticator

```bash
./bin/ytt \
    -f app/dex-k8s-authenticator/ \
    -f app/dex/values.yaml \
    -f deploy/auth/values.yaml \
| ./bin/kapp deploy --app k8s-authenticator --file -
```

XXX gangway

```bash
./bin/ytt \
    -f app/gangway/ \
    -f app/dex/values.yaml \
    -f deploy/auth/values.yaml \
    -v gangway.session.secret=${GANGWAY_SESSION_SECRET} \
    -v gangway.client.secret=${GANGWAY_CLIENT_SECRET} \
| ./bin/kapp deploy --app gangway --file -
```

XXX modify apiserver, add oidc parameters

```yaml
spec:
  containers:
  - command:
    - kube-apiserver
    #...
    - --oidc-issuer-url=https://dex.example.com
    - --oidc-client-id=gangway
    - --oidc-username-claim=email
    - --oidc-groups-claim=groups
```
