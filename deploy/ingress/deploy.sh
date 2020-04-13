if test -z "${CF_API_KEY}"; then
    echo "ERROR: Missing API key for CloudFlare."
    exit 1
fi

if ${INGRESS_HTTPS_ENABLED}; then
    DASHBOARD_HTTPS_ARGS="-f overlay/traefik/dashboard-https/"
fi
if ${INGRESS_DNS_ENABLED}; then
    if ${DEPLOY_KIND}; then
        INGRESS_KIND_ARGS="-f overlay/traefik/kind-affinity/"
        INGRESS_DNS_ARGS="-f overlay/traefik/init-dns/"
    else
        INGRESS_DNS_ARGS="-f overlay/traefik/external-dns/"
    fi
    DASHBOARD_DNS_ARGS="-f overlay/traefik/dashboard-dns/"
fi

./bin/ytt \
    -f app/traefik/ \
    ${INGRESS_KIND_ARGS} \
    ${INGRESS_DNS_ARGS} \
    -f overlay/traefik/prometheus/ \
    -f deploy/values.yaml \
    -v cloudflare.key=${CF_API_KEY} \
| ./bin/kapp deploy --app traefik-ingress --file - --yes

if ${INGRESS_MONITORING_ENABLED}; then
    ./bin/ytt \
        -f overlay/traefik/prometheus/ \
        -f deploy/base/values.yaml \
    | ./bin/kapp deploy --app traefik-monitoring --file - --yes
fi

if ${INGRESS_DASHBOARD_ENABLED}; then
    ./bin/ytt \
        -f overlay/traefik/dashboard-http/ \
        ${DASHBOARD_HTTPS_ARGS} \
        ${DASHBOARD_DNS_ARGS} \
        -f deploy/values.yaml \
    | ./bin/kapp deploy --app traefik-dashboard --file - --yes
fi
