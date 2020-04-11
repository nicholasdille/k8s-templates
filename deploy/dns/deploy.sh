if test -z "${CF_API_KEY}"; then
    echo "ERROR: Missing API key for CloudFlare."
    exit 1
fi

./bin/ytt \
    -f app/external-dns/ \
    -f deploy/values.yaml \
    -v cloudflare.key=${CF_API_KEY} \
| ./bin/kapp deploy --app external-dns --file - --yes
