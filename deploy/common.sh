set -o errexit

if test -f .env; then
    source .env
fi