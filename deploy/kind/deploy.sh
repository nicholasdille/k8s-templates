if test -z "${KIND_INTERFACE}"; then
    echo "ERROR: Missing KIND_INTERFACE."
    exit 1
fi

IP=$(ip address show dev ${KIND_INTERFACE} | grep " inet " | tr -s ' ' | cut -d' ' -f3 | cut -d'/' -f1)
if test -z "${IP}"; then
    echo "Error: Unable to determine IP address for interface ${KIND_INTERFACE}"
    exit 1
fi

case "${KIND_CNI}" in
    default)
        KIND_CNI_DEFAULT=true
    ;;
    calico)
        KIND_CNI_DEFAULT=false
    ;;
    *)
        echo "Error: Unsupported CNI requested (${KIND_CNI})."
        exit 1
    ;;
esac

if ! kind get clusters | grep --quiet ${KIND_NAME}; then
    ./bin/ytt \
        --file deploy/kind/kind.yaml \
        --file app/traefik/values.yaml \
        --file overlay/traefik/init-dns/values.yaml \
        --file app/auth/values.yaml \
        --file deploy/values.yaml \
        --data-value kind.master.ip=${IP} \
        --data-value-yaml kind.cni.default=${KIND_CNI_DEFAULT} \
    | ./bin/kind create cluster --name ${KIND_NAME} --config -
fi

while kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.conditions[?(@.reason=="KubeletReady")].status}{"\n"}{end}' | grep -E "\sFalse$"; do
    sleep 5
done

case "${KIND_CNI}" in
    calico)
        curl --silent --location https://docs.projectcalico.org/manifests/calico.yaml | kubectl apply -f -
        kubectl -n kube-system set env daemonset/calico-node FELIX_IGNORELOOSERPF=true
    ;;
esac

while kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}' | grep -E "\sFalse$"; do
    sleep 5
done
