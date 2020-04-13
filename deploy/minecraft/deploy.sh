ytt \
    -f app/minecraft/server/ \
| kapp deploy --app minecraft --file - --yes