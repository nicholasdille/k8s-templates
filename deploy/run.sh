#!/bin/bash
set -o errexit

if test "$#" != 1; then
    echo "Usage: $0 <config>"
    exit 1
fi
CONFIG=$1
if ! test -f deploy/config/${CONFIG}.sh; then
    echo "ERROR: Uable to find configuration ${CONFIG}"
    exit 1
fi

source deploy/colors.sh

if ! docker version 2>&1; then
    echo "Error: Docker not running"
    exit 1
fi
if ! make --version 2>&1; then
    echo "Error: make not found"
    exit 1
fi

make kind ytt kapp

source deploy/config/${CONFIG}.sh
source deploy/common.sh

if ${KIND_DEPLOY}; then
    source deploy/kind/deploy.sh

elif ${K3D_DEPLOY}; then
    echo "TODO: Finish support for K3D"
    exit 1
    source deploy/k3d/deploy.sh

else
    echo "### Labeling nodes"
    kubectl --namespace kube-system get pod -l component=kube-apiserver -o json \
    | jq --raw-output '.items[] | {name: .metadata.name, node: (.metadata.ownerReferences[] | select(.kind == "Node") | .name), hostip: .status.hostIP} | @base64' \
    | while read BASE64; do
        JSON=$(echo "${BASE64}" | base64 -d)

        NODE=$(echo "${JSON}" | jq --raw-output '.node')
        HOSTIP=$(echo "${JSON}" | jq --raw-output '.hostip')

        echo "### Labeling node ${NODE}"
        kubectl label node ${NODE} dille.name/public-ip=${HOSTIP}
    done
fi

./bin/kubectl apply -f deploy/namespace.yaml
export KAPP_NAMESPACE=kapp

if ${CERTIFICATE_ENABLED}; then
    source deploy/certificates/deploy.sh
fi

if ${DNS_ENABLED}; then
    source deploy/dns/deploy.sh

    if ${DNS_NODES_ENABLED}; then
        echo "### Deploying DNS records for controllers"
        kubectl get nodes -l dille.name/public-ip -o json \
        | jq  --raw-output '.items[] | {name: .metadata.name, hostip: .metadata.labels."dille.name/public-ip"} | @base64' \
        | while read BASE64; do
            JSON=$(echo "${BASE64}" | base64 -d)

            NAME=$(echo "${JSON}" | jq --raw-output '.name')
            HOSTIP=$(echo "${JSON}" | jq --raw-output '.hostip')

            ./bin/ytt \
                -f deploy/kube-apiserver-dns-template.yaml \
                -f deploy/values.yaml \
                -v apiserver.name=${NAME} \
                -v apiserver.hostip=${HOSTIP}
        done \
        | ./bin/kapp deploy --app kube-apiserver-dns --file - --yes
    fi
fi

if ${INGRESS_ENABLED}; then
    source deploy/ingress/deploy.sh
fi

if ${DASHBOARD_ENABLED}; then
    source deploy/dashboard/deploy.sh
fi

if ${MONITORING_ENABLED}; then
    source deploy/monitoring/deploy.sh

    if ${CERTIFICATE_ENABLED}; then
        source deploy/certificates/monitoring.sh
    fi

    if ${DNS_ENABLED}; then
        source deploy/dns/monitoring.sh
    fi

    if ${INGRESS_ENABLED}; then
        source deploy/ingress/monitoring.sh
    fi
fi

if ${LOG_SHIPPING_ENABLED}; then
    source deploy/log_shipping/deploy.sh
fi

if ${GRAFANA_ENABLED}; then
    source deploy/grafana/deploy.sh
fi

if ${AUTH_ENABLED}; then
    source deploy/auth/deploy.sh
fi

if ${GITLAB_ENABLED}; then
    source deploy/gitlab/deploy.sh
fi

if ${TEKTON_ENABLED}; then
    source deploy/tekton/deploy.sh
fi

if ${MINECRAFT_ENABLED}; then
    source deploy/minecraft/deploy.sh
fi
