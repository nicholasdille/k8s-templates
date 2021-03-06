if ${KIND_DEPLOY}; then
    GRAFANA_STORAGE_ARGS="-f overlay/grafana/kind-storage/"
    : "${GRAFANA_STORAGE_CLASS:=standard}"
fi
if ${INGRESS_HTTPS_ENABLED}; then
    GRAFANA_HTTPS_ARGS="-f overlay/grafana/https/"
fi
if ${INGRESS_DNS_ENABLED}; then
    GRAFANA_DNS_ARGS="-f overlay/grafana/dns/"
fi

GRAFANA_ADMIN_PASSWORD=$(openssl rand -hex 16)
GRAFANA_DATABASE_PASSWORD=$(openssl rand -hex 16)

./bin/ytt \
    -f app/grafana/ \
    ${GRAFANA_HTTPS_ARGS} \
    ${GRAFANA_DNS_ARGS} \
    ${GRAFANA_STORAGE_ARGS} \
    -f deploy/values.yaml \
    -v grafana.admin.password=${GRAFANA_ADMIN_PASSWORD} \
    -v grafana.database.password=${GRAFANA_DATABASE_PASSWORD} \
    -v grafana.volume.storageClass=${GRAFANA_STORAGE_CLASS} \
| ./bin/kapp deploy --app grafana --file - --yes
