set -o errexit

./bin/kubectl apply -f deploy/namespace.yaml
export KAPP_NAMESPACE=kapp

if test -f .env; then
    source .env
fi