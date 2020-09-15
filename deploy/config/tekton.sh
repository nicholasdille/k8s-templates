# Whether to deploy a kind cluster
KIND_DEPLOY=true
# Name of the kind cluster
KIND_NAME=demo
# Name of the primarys host interface
KIND_INTERFACE=eth0
# Name of the networking stack (supported values: default, calico)
KIND_CNI=default

# Whether to deploy the Kubernetes dashboard
DASHBOARD_ENABLED=true
# Whether to deploy cert-manager
CERTIFICATE_ENABLED=false
# Whether to deploy external-dns
DNS_ENABLED=false
# Whether to deploy traefik
INGRESS_ENABLED=true
# Whether to deploy prometheus
MONITORING_ENABLED=false
# Whether to deploy dex/gangway
AUTH_ENABLED=false

# Whether to deploy monitoring for cert-manager
CERTIFICATE_MONITORING_ENABLED=${MONITORING_ENABLED}

# Whether to deploy monitoring for external-dns
DNS_MONITORING_ENABLED=${MONITORING_ENABLED}

# Whether to deploy traefik dashboard
INGRESS_DASHBOARD_ENABLED=true
# Whether to deploy HTTPS endpoints
INGRESS_HTTPS_ENABLED=${CERTIFICATE_ENABLED}
# Whether to deploy DNS records
INGRESS_DNS_ENABLED=${DNS_ENABLED}
# Whether to deploy monitoring for traefik
INGRESS_MONITORING_ENABLED=${MONITORING_ENABLED}

# Whether to fix kube-proxy for monitoring
MONITORING_FIX_KUBEPROXY_ENABLED=false
# Whether to deploy service|pod monitors
MONITORING_TARGETS_ENABLED=false
# Whether to deploy ingress for prometheus
MONITORING_INGRESS_ENABLED=${INGRESS_ENABLED}

# Whether to deploy log shipping
LOG_SHIPPING_ENABLED=false

# Whether to deploy grafana
GRAFANA_ENABLED=false

# Whether to deploy GitLab
GITLAB_ENABLED=false

# Whether to deploy tekton pipelines
TEKTON_ENABLED=true

# Whether to deploy minecraft
MINECRAFT_ENABLED=false
