GREEN="\e[92m"
YELLOW="\e[93m"
RED="\e[91m"
DEFAULT="\e[39m"

echo_color() {
    local color=${1^^}
    local message=$2

    echo -e "${!color}$message${DEFAULT}"
}
