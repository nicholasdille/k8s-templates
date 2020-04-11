if ${MONITORING_FIX_KUBEPROXY_ENABLED} && ./bin/kubectl -n kube-system get configmaps kube-proxy | grep --quiet --invert-match "metricsBindAddress: 0.0.0.0:10249"; then
    ./bin/kubectl -n kube-system get configmaps kube-proxy -o yaml | \
        sed 's/metricsBindAddress: 127.0.0.1:10249/metricsBindAddress: 0.0.0.0:10249/' | \
        sed 's/metricsBindAddress: ""/metricsBindAddress: 0.0.0.0:10249/' | \
        ./bin/kubectl apply -f -
    ./bin/kubectl -n kube-system get pod -l k8s-app=kube-proxy -o name | xargs ./bin/kubectl -n kube-system delete
fi

./bin/ytt \
    -f app/prometheus/operator/ \
| ./bin/kapp deploy --app prometheus-operator --file - --yes

sleep 10

./bin/ytt \
    -f app/prometheus/instance/ \
| ./bin/kapp deploy --app prometheus --file - --yes

./bin/ytt \
    -f app/prometheus/node-exporter/ \
    -f app/prometheus/operator/values.yaml \
| ./bin/kapp deploy --app node-exporter --file - --yes

./bin/ytt \
    -f app/kube-state-metrics/ \
| ./bin/kapp deploy --app kube-state-metrics --file - --yes

if ${MONITORING_TARGETS_ENABLED}; then
    ./bin/ytt \
        -f app/prometheus/servicemonitors/ \
        -f app/prometheus/operator/values.yaml \
    | ./bin/kapp deploy --app servicemonitors --file - --yes
fi

if ${MONITORING_INGRESS_ENABLED}; then
    echo "TODO: Flag MONITORNG_INGRESS_ENABLED not implemented yet."
fi
