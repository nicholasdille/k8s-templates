if ${CERTIFICATE_MONITORING_ENABLED}; then
    echo "### Deploying certificate monitoring"
    ./bin/ytt \
        -f overlay/cert-manager/monitoring/ \
        -f app/cert-manager/values.yaml \
        -f deploy/values.yaml \
    | ./bin/kapp deploy --app cert-manager-monitoring --file - --yes
fi
