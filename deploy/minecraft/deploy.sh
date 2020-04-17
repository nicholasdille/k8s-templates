./bin/ytt \
    -f app/minecraft/server/ \
    -f deploy/values.yaml \
| ./bin/kapp deploy --app minecraft --file - --yes