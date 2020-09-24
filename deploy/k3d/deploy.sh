if test -z "${K3D_INTERFACE}"; then
    echo "ERROR: Missing K3D_INTERFACE."
    exit 1
fi

IP=$(ip address show dev ${K3D_INTERFACE} | grep " inet " | tr -s ' ' | cut -d' ' -f3 | cut -d'/' -f1)
if test -z "${IP}"; then
    echo "Error: Unable to determine IP address for interface ${K3D_INTERFACE}"
    exit 1
fi

if ! k3d cluster list | grep --quiet ${K3D_NAME}; then
    ./bin/k3d cluster create demo --agents 1 --no-lb --port 80:80@agent[0] --port 443:443@agent[0]
    sleep 5
fi

while kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.conditions[?(@.reason=="KubeletReady")].status}{"\n"}{end}' | grep -E "\sFalse$"; do
    sleep 5
done

while kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\t"}{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}' | grep -vE "\sSucceeded\s" | grep -E "\sFalse$"; do
    sleep 5
done

kubectl label node k3d-${K3D_NAME}-agent-0 dille.name/public-ip=${IP}
