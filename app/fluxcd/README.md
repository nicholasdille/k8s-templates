# App for `fluxcd`

XXX https://github.com/fluxcd

XXX https://github.com/fluxcd/flux/tree/v1.19.0/deploy

XXX install `fluxctl`

```bash
curl -s https://api.github.com/repos/fluxcd/flux/releases/latest \
| jq --raw-output '.assets[] | select(.name == "fluxctl_linux_amd64") | .browser_download_url' \
| xargs curl -Lfo /usr/local/bin/fluxctl
chmod +x /usr/local/bin/fluxctl
source <(fluxctl completion bash)
```

## Example

XXX

```bash
./bin/ytt \
    -f app/fluxcd/ \
    -v flux.git.repository=git@github.com:nicholasdille/flux-ytt \
    -v flux.git.user=nicholasdille \
    -v flux.git.email=nicholasdille@users.noreply.github.com \
| ./bin/kapp deploy --app flux --file - --yes
```
