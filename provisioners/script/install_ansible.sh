#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Install Ansible in a virtual environment
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
###############################################################################
install() {
  python3.12 -m venv "${HOME}/.venv/ansible"
  source "${HOME}/.venv/ansible/bin/activate"

  local -r required_version="11.3.0"
  local -r version="$(pip3 list --format=json | jq -r '.[] | select(.name=="ansible") | .version')"

  if [[ "${version}" != "${required_version}" ]]; then
    echo "Installing Ansible ${required_version}"
    pip3 install ansible==${required_version} &> /dev/null
  fi

  deactivate
}

main() {
  pushd "${MY_PATH}" &> /dev/null

  install

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