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
    -v dex.gitlab.id=${GITLAB_APPLICATION_ID} \
    -v dex.gitlab.secret=${GITLAB_APPLICATION_SECRET} \
    -v gangway.session.secret=${GANGWAY_SESSION_SECRET} \
    -v gangway.client.secret=${GANGWAY_CLIENT_SECRET} \
| ./bin/kapp deploy --app auth --file - --yes
