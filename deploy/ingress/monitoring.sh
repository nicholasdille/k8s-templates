if ${INGRESS_MONITORING_ENABLED}; then
    echo "### Deploying ingress monitoring"
    ./bin/ytt \
        -f overlay/traefik/prometheus/ \
        -f app/traefik/values.yaml \
        -f deploy/values.yaml \
    | ./bin/kapp deploy --app traefik-monitoring --file - --yes
fi
