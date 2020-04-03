#!/bin/bash
set -o errexit

export KAPP_NAMESPACE=kapp

source .env

./bin/ytt \
    -f app/dex/ \
    -f app/gangway/values.yaml \
    -f app/dex-k8s-authenticator/values.yaml \
    -f deploy/auth/values.yaml \
    -v dex.admin.password=${DEX_ADMIN_PASSWORD} \
    -v dex.gitlabcom.id=${GITLAB_APPLICATION_ID} \
    -v dex.gitlabcom.secret=${GITLAB_APPLICATION_SECRET} \
    -v gangway.client.secret=${GANGWAY_CLIENT_SECRET} \
| ./bin/kapp deploy --app dex --file - --yes

./bin/ytt \
    -f app/dex-k8s-authenticator/ \
    -f app/dex/values.yaml \
    -f deploy/auth/values.yaml \
| ./bin/kapp deploy --app k8s-authenticator --file - --yes

./bin/ytt \
    -f app/gangway/ \
    -f app/dex/values.yaml \
    -f deploy/auth/values.yaml \
    -v gangway.session.secret=${GANGWAY_SESSION_SECRET} \
    -v gangway.client.secret=${GANGWAY_CLIENT_SECRET} \
| ./bin/kapp deploy --app gangway --file - --yes
