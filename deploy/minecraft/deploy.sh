#!/bin/bash
set -o errexit

BASEDIR="$(dirname $(readlink -f $0))/../.."
source "${BASEDIR}/lib/colors.sh"

echo_color green "### Deploying minecraft..."
ytt -f app/minecraft/server/ | kapp deploy --app minecraft --file -