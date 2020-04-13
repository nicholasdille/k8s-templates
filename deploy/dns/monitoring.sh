if ${DNS_MONITORING_ENABLED}; then
    echo "### Deploying DNS monitoring"
    ./bin/ytt \
        -f overlay/external-dns/monitoring/ \
        -f app/external-dns/values.yaml \
        -f deploy/values.yaml \
    | ./bin/kapp deploy --app external-dns-monitoring --file - --yes
fi
