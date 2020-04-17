mkdir backup

kubectl get certificate --all-namespaces -o json \
| jq --raw-output '.items[] | {name: .metadata.name, namespace: .metadata.namespace, secret: .spec.secretName} | @base64' \
| while read CERT; do
    JSON=$(echo "${CERT}" | base64 -d | jq .)
    NAME=$(echo "${JSON}" | jq --raw-output '.name')
    NAMESPACE=$(echo "${JSON}" | jq --raw-output '.namespace')
    SECRET=$(echo "${JSON}" | jq --raw-output '.secret')

    echo ---
    kubectl --namespace ${NAMESPACE} get certificate ${NAME} -o yaml
    echo ---
    kubectl --namespace ${NAMESPACE} get secret ${SECRET} -o yaml
done >backup/certificates.yaml