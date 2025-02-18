#!/bin/bash

### Trap signals
signal_exit() {
  local l_signal
  l_signal="$1"

  case "$l_signal" in
  INT)
    error_exit "Program interrupted by user"
    ;;
  TERM)
    error_exit "Program terminated"
    ;;
  *)
    error_exit "Terminating on unknown signal"
    ;;
  esac
}

trap "signal_exit TERM" TERM HUP
trap "signal_exit INT" INT

### Const
readonly PROGRAM_NAME=${0##*/}
readonly PROGRAM_VERSION="1.0.0"
readonly EXTERNAL_BINARIES="jq curl"
readonly EXTERNAL_SOURCES=""

### Args
LOG_LEVEL="STABLE"

### Welcome
printf "Hello %s - Welcome to %s v%s\n" "$(whoami)" "$PROGRAM_NAME" "$PROGRAM_VERSION"

# Helpers
clean_up() {
  return
}

error_exit() {
  local l_error_message
  l_error_message="$1"

  printf "[ERROR] - %s\n" "${l_error_message:-'Unknown Error'}" >&2
  echo "Exiting with exit code 1"
  clean_up
  exit 1
}

graceful_exit() {
  clean_up
  exit 0
}

load_libraries() {
  for _ext_bin in $EXTERNAL_BINARIES; do
    if ! hash "$_ext_bin" &>/dev/null; then
      error_exit "Required binary $_ext_bin not found."
    fi
  done
}

load_sources() {
  for _ext_src in $EXTERNAL_SOURCES; do
    # shellcheck disable=SC1090
    if bash $_ext_src --check &>/dev/null; then
      source $_ext_src
      echo "Loaded $_ext_src"
    else
      error_exit "[$_ext_src] - Check library returned non-zero code"
    fi
  done
}

help_message() {
  cat <<-_EOF_

Description  : Git clone via SSH a set of project under a specific groupId,
               projects will be cloned in launch directory.
Example usage:

Options:
  [-h | --help]                      Display this help message
  [-v | --verbose]        (OPTIONAL) More verbose output
  [--trace]               (OPTIONAL) Set -o xtrace
  [--version]                        Show program version
_EOF_
  return
}

### Func
log_debug() {
  local l_message
  l_message="$1"

  if [ $LOG_LEVEL == "DEBUG" ]; then
    echo "[DEBUG] - $l_message"
  fi
}

log_info() {
  local l_message
  l_message="$1"
  echo "[INFO] - $l_message"
}

log_error() {
  local l_message
  l_message="$1"
  echo "[ERROR] - $l_message"
}

ask_user_permission() {
  local l_message
  l_message="$1"

  printf "%s (y/n): " "$l_message"

  local l_continue
  read -r l_continue

  if [ "$l_continue" == "y" ]; then
    echo "OK"
  elif [ "$l_continue" == "n" ]; then
    graceful_exit
  else
    echo "Invalid choice [$l_continue]! Retrying..."
    ask_user_permission "$l_message"
  fi
}

### Check binaries
load_libraries

### Load Sources
load_sources

### Parse args
while [[ -n "$1" ]]; do
  case "$1" in
  -h | --help)
    help_message
    graceful_exit
    ;;
  -v | --verbose)
    LOG_LEVEL="DEBUG"
    ;;
  --trace)
    set -o xtrace
    ;;
  --version)
    printf "Running version: %s\n" "$PROGRAM_VERSION"
    graceful_exit
    ;;
  --organization)
    ORGANIZATION_NAME=$2
    ;;
  --token)
    TOKEN=$2
    ;;
  --* | -*)
    usage >&2
    error_exit "Unknown option $1"
    ;;
  esac
  shift
done

### Checking args

### Main logic
echo "Fetching repositories for organization: $ORGANIZATION_NAME"

curl -s -H "Authorization: Bearer $TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     "https://api.github.com/orgs/$ORGANIZATION_NAME/repos?per_page=10000000" | jq '.[] | .name'
### Finalize
graceful_exit
