#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Install system dependencies
# Globals:
#   None
# Arguments:
#   error_message
# Returns:
#   None
###############################################################################
install_dependencies() {
  echo 'Installing system dependencies'
  yum install -y jq python3 python3.12 python3.12-pip &> /dev/null
}

main() {
  pushd "${MY_PATH}" &> /dev/null

  is_user 'root'
  install_dependencies

  popd &> /dev/null
}

echo "**** $(basename "$0") ****"

MY_PATH="$(dirname "$0")"
MY_PATH="$(cd "${MY_PATH}" && pwd)"
readonly MY_PATH

source "${MY_PATH}/common_functions.sh"

main "$@"

echo "**** $(basename "$0") - done ****"

exit 0
