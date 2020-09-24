echo "###"
echo "### Deploy DNS started"
echo "###"

if test -z "${CF_API_KEY}"; then
    echo "ERROR: Missing API key for CloudFlare. Set CF_API_KEY."
    exit 1
fi

echo "### Deploying DNS"
./bin/ytt \
    -f app/external-dns/ \
    -f deploy/values.yaml \
    -v cloudflare.key=${CF_API_KEY} \
| ./bin/kapp deploy --app external-dns --file - --yes

echo "###"
echo "### Deploy DNS finished"
echo "###"
