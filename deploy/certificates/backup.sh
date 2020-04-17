kubectl get clusterissuer -o name \
| cut -d/ -f2 \
| while read ISSUER; do
    if test "$(\
            kubectl get clusterissuer ${ISSUER} -o json \
            | jq -r '.status.conditions[] | select(.reason == "ACMEAccountRegistered") | select(.type == "Ready") | .status'\
            )" == "True"; then

        echo "---"
        kubectl --namespace cert-manager get secret ${ISSUER} -o yaml
    fi

done >backup/clusterissuers.yaml

kubectl get certificate --all-namespaces -o json \
| jq --raw-output '.items[] | select(.status.conditions[].reason == "Ready") | select(.status.conditions[].status == "True") | {name: .metadata.name, namespace: .metadata.namespace, secret: .spec.secretName} | @base64' \
| while read CERT; do

    JSON=$(echo "${CERT}" | base64 -d)

    NAME=$(echo "${JSON}" | jq --raw-output '.name')
    NAMESPACE=$(echo "${JSON}" | jq --raw-output '.namespace')
    SECRET=$(echo "${JSON}" | jq --raw-output '.secret')

    echo ---
    kubectl get namespace ${NAMESPACE} -o yaml

    echo ---
    kubectl --namespace ${NAMESPACE} get certificate ${NAME} -o yaml

done >backup/certificates.yaml
