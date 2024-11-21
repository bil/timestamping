#!/bin/bash

set -u

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/TSA.source

DIR_DATA=$1
DIR_ORIGIN=$(pwd)
FILE_CA=$SCRIPT_DIR/../CA
DIGEST_SIZE=256

# check for Mac
if [ "$(uname)" = "Darwin" ]; then
    CMD_SHA="shasum -a $DIGEST_SIZE"
else
    CMD_SHA="sha${DIGEST_SIZE}sum"
fi

cd $DIR_DATA
DIGEST_DATA=$(find ./ -type f -exec $CMD_SHA {} \; | $CMD_SHA | cut -c 1-$(($DIGEST_SIZE/4)) )

cd $DIR_ORIGIN
for TSA_idx in $(seq 0 $((${#TSA_names[@]}-1)) ); do

  echo "Verifying ${TSA_names[$TSA_idx]}:"

  openssl ts -verify -digest $DIGEST_DATA \
      -in timestampReply-${TSA_names[$TSA_idx]}.tsr \
      -CApath $FILE_CA
done
