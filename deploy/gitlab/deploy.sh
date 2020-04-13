./bin/ytt \
    -f app/gitlab/ \
| kapp deploy --app gitlab --file - --yes
