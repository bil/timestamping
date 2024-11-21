#!/bin/bash

set -u

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/TSA.source

FILE_DATA=$1
DIR_CA=$SCRIPT_DIR/../CA

for TSA_idx in $(seq 0 $((${#TSA_names[@]}-1)) ); do

  echo "Verifying ${TSA_names[$TSA_idx]}:"

  openssl ts -verify -data $FILE_DATA \
      -in timestampReply_${TSA_names[$TSA_idx]}.tsr \
      -CApath $DIR_CA

done
