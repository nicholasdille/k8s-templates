# App for Bitnami Sealed Secrets

XXX https://github.com/bitnami-labs/sealed-secrets

XXX based on 0.9.7

XXX installation of CLI

```bash
curl -s https://api.github.com/repos/bitnami-labs/sealed-secrets/releases/latest | \
    jq --raw-output '.assets[] | select(.name | endswith("-linux-amd64")) | .browser_download_url' | \
    xargs curl -sLfo ~/.local/bin/kubeseal
chmod ~/.local/bin/kubeseal
```

XXX https://github.com/bitnami-labs/sealed-secrets#usage