if ${INGRESS_ENABLED} && ${CERTIFICATE_ENABLED}; then
    DASHBOARD_CERTIFICATE_ARGS="-f overlay/k8s-dashboard/https/"
fi
if ${DNS_ENABLED}; then
    DASHBOARD_DNS_ARGS="-f overlay/k8s-dashboard/dns/"
fi

./bin/ytt \
    -f app/k8s-dashboard/ \
    ${DASHBOARD_CERTIFICATE_ARGS} \
    ${DASHBOARD_DNS_ARGS} \
    -f deploy/values.yaml \
| ./bin/kapp deploy --app k8s-dashboard --file - --yes
