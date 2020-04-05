#!/bin/bash
set -o errexit

export KAPP_NAMESPACE=kapp

if test -f .env; then
    source .env
fi

./bin/ytt \
    -f app/auth/ \
    -f deploy/auth/values.yaml \
    -v openldap.password.admin=${OPENLDAP_ADMIN_PASSWORD} \
    -v dex.admin.password=${DEX_ADMIN_PASSWORD} \
    -v dex.gitlabcom.id=${GITLAB_APPLICATION_ID} \
    -v dex.gitlabcom.secret=${GITLAB_APPLICATION_SECRET} \
    -v gangway.session.secret=${GANGWAY_SESSION_SECRET} \
    -v gangway.client.secret=${GANGWAY_CLIENT_SECRET} \
| ./bin/kapp deploy --app gangway --file - --yes
