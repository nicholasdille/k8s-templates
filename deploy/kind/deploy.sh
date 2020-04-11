if test -z "${KIND_INTERFACE}"; then
    echo "ERROR: Missing KIND_INTERFACE."
    exit 1
fi

IP=$(ip address show dev ${KIND_INTERFACE} | grep " inet " | tr -s ' ' | cut -d' ' -f3 | cut -d'/' -f1)
if [[ -z "${IP}" ]]; then
    echo "Error: Unable to determine IP address for interface ${KIND_INTERFACE}"
    exit 1
fi

if ! kind get clusters | grep --quiet ${KIND_NAME}; then
    ./bin/ytt \
        -f deploy/base/kind/kind.yaml \
        -f app/traefik/init-dns/values.yaml \
        -f deploy/base/values.yaml \
        -v kind.master.ip=${IP} \
    | ./bin/kind create cluster --name ${KIND_NAME} --config -
fi
