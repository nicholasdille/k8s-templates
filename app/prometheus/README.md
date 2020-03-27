# App for Prometheus

XXX operator

XXX kube-proxy

```bash
kubectl -n kube-system get configmaps kube-proxy -o yaml | \
    sed 's/metricsBindAddress: 127.0.0.1:10249/metricsBindAddress: 0.0.0.0:10249/' | \
    sed 's/metricsBindAddress: ""/metricsBindAddress: 0.0.0.0:10249/' | \
    kubectl apply -f -
```
