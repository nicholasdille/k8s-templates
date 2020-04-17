./bin/ytt \
    -f app/gitlab/ \
    -f deploy/values.yaml \
| ./bin/kapp deploy --app gitlab --file - --yes
