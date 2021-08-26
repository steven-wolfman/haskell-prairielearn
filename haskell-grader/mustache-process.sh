#!/usr/bin/env bash
shopt -s globstar

# Plan:
# + Takes as a parameter the name of a .json file to use for mustache formatting. Defaults to /grade/data/data.json
#   Call this DATA_SOURCE
# + Locate any file under the current directory that ends in .mustache; for each such file {}:
#   + run mustache ${DATA_SOUCE} {} > $(basename {} .mustache)

DEFAULT_DATA_SOURCE=/grade/data/data.json
DATA_SOURCE=${1-$DEFAULT_DATA_SOURCE}

if [[ ! -x "${DATA_SOURCE}" ]]
then
    echo "Error: Data source not found at \"${DATA_SOURCE}\""
    exit 1
fi

for i in **/?*.mustache
do
    echo "Processing ${i} using ${DATA_SOURCE}."
    basei="${i%.mustache}"
    mustache "${DATA_SOURCE}" "${i}" > "${basei}"
done
