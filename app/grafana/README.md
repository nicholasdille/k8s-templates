# App for grafana

XXX

## Example

XXX

```bash
./bin/ytt \
    -f app/grafana/ \
    -f deploy/base/values.yaml \
    -v grafana.admin.password=$(openssl rand -hex 16) \
    -v grafana.database.password=$(openssl rand -hex 16) \
| ./bin/kapp deploy --app grafana --file - --yes
```
