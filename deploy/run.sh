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

if ${KIND_DEPLOY}; then
    source deploy/kind/deploy.sh
fi

source deploy/common.sh

if ${CERTIFICATE_ENABLED}; then
    source deploy/certificate/deploy.sh
fi

if ${DNS_ENABLED}; then
    source deploy/dns/deploy.sh
fi

if ${INGRESS_ENABLED}; then
    source deploy/ingress/deploy.sh
fi

if ${MONITORING_ENABLED}; then
    source deploy/monitoring/deploy.sh
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
