#!/usr/bin/env bash

# Mustache processing intended primarily for use with PrairieLearn external graders.
# Bash script template based on https://betterdev.blog/minimal-safe-bash-script-template/

set -Eeuo pipefail
shopt -s globstar extglob nullglob

MUSTACHE_FILE_PATTERN=".mustache"
EXTENSION_GLOB="**/?*${MUSTACHE_FILE_PATTERN}?(.*)"
DEFAULT_DATA_SOURCE=/grade/data/data.json
DATA_SOURCE="${DEFAULT_DATA_SOURCE}"

USAGE=$(cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [<formatter>]

Mustache expansion for files in the current subtree with the extension ${MUSTACHE_FILE_PATTERN}.
Results are placed in files with matching paths but without the ${MUSTACHE_FILE_PATTERN} extension.
Formats using <formatter> (defaulting to "${DEFAULT_DATA_SOURCE}").

The extension ${MUSTACHE_FILE_PATTERN} can appear anywhere in the filename
(set off by periods) except at the start, e.g., "foo${MUSTACHE_FILE_PATTERN}.txt".
The subtree is defined by "**"; so, hidden directories are not processed.

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
    msg "Using default formatter location: ${DATA_SOURCE}"
  fi

  # Check for disallowed arguments:
  [[ $# -gt 0 ]] && dieUI "Too many arguments provided"

  return 0
}

parse_params "$@"

# script logic here

if [[ ! -x $(command -v mustache) ]]
then
    die "mustache command not found; see https://mustache.github.io/"
fi

if [[ ! -f "${DATA_SOURCE}" ]]
then
    die "No formatter file found at: ${DATA_SOURCE}"
fi

msg "Using formatter: ${DATA_SOURCE}"

# Test formatting of data source
mustache "${DATA_SOURCE}" /dev/null 2> /dev/null || die "Not recognized as valid YAML/JSON formatter: ${DATA_SOURCE}"

matches=($EXTENSION_GLOB)
msg "Processing ${MUSTACHE_FILE_PATTERN} files."
for i in "${matches[@]}"
do
    basei="${i/.mustache/}"
    msg "  Processing ${i}"
    mustache "${DATA_SOURCE}" "${i}" > "${basei}"
done
msg "Done processing ${MUSTACHE_FILE_PATTERN} files."
