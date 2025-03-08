#!/usr/bin/env bash

###############################################################################
# Common functions
###############################################################################

###############################################################################
# Abort the execution of the script outputting an appropriate error message
# Globals:
#   None
# Arguments:
#   error_message
# Returns:
#   None
###############################################################################
abort() {
  local -r error_message="${1}"

  echo "[FATAL] ${error_message}" >&2
  exit 1
}

###############################################################################
# Check the script is running under the required user, abort if this is not the
# case
# Globals:
#   None
# Arguments:
#   required_user
# Returns:
#   None
###############################################################################
is_user() {
  local -r required_user="${1}"

  if [[ $(id -un) != "${required_user}" ]]; then
    abort "This script has to be run as ${required_user} user"
  fi
}
