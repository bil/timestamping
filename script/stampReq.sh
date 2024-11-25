#!/bin/bash

set -u

DIR_SCRIPT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $DIR_SCRIPT/TSA.source

FILE_REQ=$1

for TSA_idx in $(seq 0 $((${#TSA_names[@]}-1)) ); do

  curl -s -S ${TSA_urls[$TSA_idx]} \
    -H 'Content-Type: application/timestamp-query' \
    --data-binary @$FILE_REQ \
    -o tsReply_${TSA_names[$TSA_idx]}.tsr

done
