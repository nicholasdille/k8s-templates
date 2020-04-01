# Deployment of authentication layer

XXX https://github.com/alexbrand/gangway-dex-tutorial/tree/master/deployment/dex

XXX integration for gitlab.com

XXX create dex admin password `admin_password`: htpasswd -bnBC 10 "" test123 | tr -d ':\n'

XXX create gangway client secret `client_secret`: openssl rand -hex 32

XXX gangway session secret `session_secret`: openssl rand -base64 32

XXX dex

```bash
./bin/ytt \
    -f app/dex/ \
    -f app/gangway/values.yaml \
    -f deploy/auth/values.yaml \
    -v dex.admin.password=<admin_password> \
    -v dex.gitlabcom.id=<gitlab_com_application_id> \
    -v dex.gitlabcom.secret=<gitlab_com_application_secret> \
    -v gangway.client.secret=<client_secret> \
| ./bin/kapp deploy --app dex --file -
```

XXX gangway

```bash
./bin/ytt \
    -f app/gangway/ \
    -f app/dex/values.yaml \
    -f deploy/auth/values.yaml \
    -v gangway.session.secret=<session_secret>
    -v gangway.client.secret=<client_secret> \
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
