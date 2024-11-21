#!/bin/bash

set -u

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/TSA.source

FILE_REQ=$1

for TSA_idx in $(seq 0 $((${#TSA_names[@]}-1)) ); do

  curl -s -S ${TSA_urls[$TSA_idx]} \
    -H 'Content-Type: application/timestamp-query' \
    --data-binary @$FILE_REQ \
    -o timestampReply-${TSA_names[$TSA_idx]}.tsr

done
