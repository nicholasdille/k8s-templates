if ! ${INGRESS_ENABLED}; then
    echo "ERROR: Flag AUTH_ENABLED requires INGRESS_ENABLED"
    exit 1
fi
if ! ${CERTIFICATE_ENABLED}; then
    echo "ERROR: Flag AUTH_ENABLED requires CERTIFICATE_ENABLED"
    exit 1
fi
if ! ${DNS_ENABLED}; then
    echo "ERROR: Flag AUTH_ENABLED requires DNS_ENABLED"
    exit 1
fi

OPENLDAP_ADMIN_PASSWORD=$(openssl rand -hex 32)
GANGWAY_SESSION_SECRET=$(openssl rand -base64 32)
GANGWAY_CLIENT_SECRET=$(openssl rand -hex 32)

./bin/ytt \
    -f app/auth/ \
    -f deploy/auth/values.yaml \
    -f deploy/values.yaml
    -v openldap.password.admin=${OPENLDAP_ADMIN_PASSWORD} \
    -v gangway.session.secret=${GANGWAY_SESSION_SECRET} \
    -v gangway.client.secret=${GANGWAY_CLIENT_SECRET} \
| ./bin/kapp deploy --app auth --file - --yes
