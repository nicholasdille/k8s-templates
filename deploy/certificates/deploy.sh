if test -z "${CF_API_KEY}"; then
    echo "ERROR: Missing API key for CloudFlare. Set CF_API_KEY."
    exit 1
fi

./bin/ytt \
    -f app/cert-manager/base/ \
    -f deploy/values.yaml \
| ./bin/kapp deploy --app cert-manager --file - --yes

if test -f backup/clusterissuers.yaml; then
    kubectl apply -f backup/clusterissuers.yaml
fi

./bin/ytt \
    -f app/cert-manager/letsencrypt-cloudflare/ \
    -f deploy/values.yaml \
    -v cloudflare.key=${CF_API_KEY} \
| ./bin/kapp deploy --app cert-manager-issuer --file - --yes

if test -f backup/certificates.yaml; then
    kubectl apply -f backup/certificates.yaml
fi
