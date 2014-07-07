#!/bin/bash

set -ex

# check to see if "ovftool" & "packer" are in PATH
command -v ovftool >/dev/null 2>&1 || \
  { echo "I require ovftool but it's not installed. Aborting." >&2; exit 1; }
command -v packer >/dev/null 2>&1 || \
  { echo "I require packer but it's not installed. Aborting." >&2; exit 1; }


# parse CLI args
OPT_OUTPUT_DIR=output
OPT_VCSA_OVA_URL=

while getopts "o:u:" opt; do
  case $opt in
    o) OPT_OUTPUT_DIR="$OPTARG"
       ;;
    u) OPT_VCSA_OVA_URL="$OPTARG"
       ;;
    *) echo "invalid option: $1" 1>&2;
    ;;
  esac
done

if [ -z $OPT_VCSA_OVA_URL ]; then
  echo "Error: URL to VCSA OVA file must be specified with: '-u <URL>'"
  exit 100
fi


# create output directory
rm -rf $OPT_OUTPUT_DIR
mkdir -p $OPT_OUTPUT_DIR

# unpack the OVA into a VMX so that packer can ingest it. then run packer.
ovftool --sourceType=OVA --targetType=VMX \
  "$OPT_VCSA_OVA_URL" \
  "$OPT_OUTPUT_DIR/vcsa-55.vmx"

packer build vcenter-55-simulator.json
