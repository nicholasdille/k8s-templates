#!/bin/bash
set -o errexit

DEPLOY_DIR=$(dirname $(readlink -f $0))
BASE_DIR="${DEPLOY_DIR}/../.."
source "${BASE_DIR}/lib/colors.sh"
YTT="${BASE_DIR}/bin/ytt"


${YTT} -f app/registry/base -f app/registry/web -f app/gitea/base -f app/drone/server -f app/drone/server-gitea -f app/drone/agent-k8s -f ${DEPLOY_DIR}/values.yaml
