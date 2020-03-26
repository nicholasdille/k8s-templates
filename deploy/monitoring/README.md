# How to deploy cluster monitoring

XXX deploy kind

```bash
kind create cluster --name test --config deploy/monitoring/kind.yaml
kubectl create namespace kapp
export KAPP_NAMESPACE=kapp
```

XXX deploy operator

```bash
./bin/ytt -f app/prometheus/operator/ | ./bin/kapp deploy --app prometheus-operator --file -
```

XXX deploy instance

```bash
./bin/ytt -f app/prometheus/instance/ | ./bin/kapp deploy --app prometheus --file -
```

XXX deploy servicemonitors

```bash
./bin/ytt -f app/prometheus/servicemonitors/ -f app/prometheus/operator/values.yaml | ./bin/kapp deploy --app servicemonitors --file -
```

XXX deploy node-exporter

```bash
./bin/ytt -f app/prometheus/node-exporter/ | ./bin/kapp deploy --app node-exporter --file -
```

XXX deploy kube-state-metrics

```bash
./bin/ytt -f app/kube-state-metrics/ | ./bin/kapp deploy --app kube-state-metrics --file -
```

XXX WIP: deploy grafana

XXX WIP: deploy grafana visualization
