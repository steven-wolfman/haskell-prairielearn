#!/usr/bin/env bash

# Mustache processing intended primarily for use with PrairieLearn external graders.
# Bash script template based on https://betterdev.blog/minimal-safe-bash-script-template/

set -Eeuo pipefail
shopt -s globstar

DEFAULT_DATA_SOURCE=/grade/data/data.json
DATA_SOURCE="${DEFAULT_DATA_SOURCE}"

USAGE=$(cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [<formatter>]

Mustache expansion for files in the current subtree with the extension .mustace.
Results are placed in files with matching paths but without the .mustache extension.
Formats using <formatter> (defaulting to "${DEFAULT_DATA_SOURCE}").

Assumes the availability of 'mustache' program on path. Does not process files
named exactly '.mustache'. The subtree rooted at CWD is defined by the "**" pattern.

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info (bash -x option)
EOF
)

usage() {
  echo "${USAGE}"
  exit
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

dieUI() {
  local msg=$1
  local code=${2-1}
  msg "$msg"
  msg "\n${USAGE}"
  exit "$code"
}

parse_params() {
  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    -?*) dieUI "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  # Optional argument
  if [[ $# -gt 0 ]]
  then
    DATA_SOURCE="${1-}"
    shift
  else
    msg "Using default formatter at: ${DATA_SOURCE}"
  fi

  # Check for disallowed arguments:
  [[ $# -gt 0 ]] && dieUI "Too many arguments provided"

  return 0
}

parse_params "$@"

# script logic here

if [[ ! -f "${DATA_SOURCE}" ]]
then
    die "No file found at: ${DATA_SOURCE}"
fi

msg "Using formatter: ${DATA_SOURCE}"

for i in **/?*.mustache
do
    basei="${i%.mustache}"
    msg "Processing ${i}"
    mustache "${DATA_SOURCE}" "${i}" > "${basei}"
done
