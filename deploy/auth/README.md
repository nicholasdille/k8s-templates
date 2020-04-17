# Deployment of authentication layer

XXX also integrated into `deploy/base`

XXX integration for gitlab.com in GITLAB_APPLICATION_ID and GITLAB_APPLICATION_SECRET

XXX create gangway client secret `client_secret`: openssl rand -hex 32

```bash
GANGWAY_CLIENT_SECRET=$(openssl rand -hex 32)
```

XXX gangway session secret `session_secret`: openssl rand -base64 32

```bash
GANGWAY_SESSION_SECRET=$(openssl rand -base64 32)
```

XXX openldap admin password

```bash
OPENLDAP_ADMIN_PASSWORD=$(openssl rand -hex 32)
```

XXX deploy

```bash
./bin/ytt \
    -f app/auth/ \
    -v openldap.password.admin=${OPENLDAP_ADMIN_PASSWORD} \
    -v dex.gitlab.id=${GITLAB_APPLICATION_ID} \
    -v dex.gitlab.secret=${GITLAB_APPLICATION_SECRET} \
    -v gangway.session.secret=${GANGWAY_SESSION_SECRET} \
    -v gangway.client.secret=${GANGWAY_CLIENT_SECRET} \
| ./bin/kapp deploy --app auth --file -
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
