if ${KIND_DEPLOY}; then
    : "${TEKTON_STORAGE_CLASS:=standard}"
fi


if test -z "${TEKTON_STORAGE_CLASS}"; then
    echo "ERROR: Missing TEKTON_STORAGE_CLASS."
    exit 1
fi

./bin/ytt \
    -f app/tekton/ \
    -v tekton.volume.storageClass=${TEKTON_STORAGE_CLASS} \
| ./bin/kapp deploy --app tekton --file - --yes
