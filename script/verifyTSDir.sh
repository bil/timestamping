#!/bin/bash

set -u

DIR_SCRIPT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $DIR_SCRIPT/TSA.source

DIR_DATA=$1
DIR_ORIGIN=$(pwd)
DIR_CA=$DIR_SCRIPT/../CA
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

  # make tmp directory for this tsr
  DIR_TMP=$(mktemp -d /tmp/tsVerify.XXXXXXX)
  cd $DIR_TMP

  # extract certificates from timestamp
  $DIR_SCRIPT/tsr2cert.sh $DIR_ORIGIN/tsReply_${TSA_names[$TSA_idx]}.tsr
  # split cert chain pem into individual certificates
  csplit -s -f tsReply_${TSA_names[$TSA_idx]} -b %02d.pem tsReply_${TSA_names[$TSA_idx]}.pem /END\ CERTIFICATE/+2 {*}
  # delete empty file
  find $DIR_TMP -size 0 -delete
  # delete cert chain pem
  rm tsReply_${TSA_names[$TSA_idx]}.pem

  # generate cert IDs
  openssl rehash ./
  # copy over root CAs, overwriting links to any extracted CA root with these root certs
  cp -a $DIR_SCRIPT/../CA/* $DIR_TMP

  cd $DIR_ORIGIN
  openssl ts -verify -digest $DIGEST_DATA \
      -in tsReply_${TSA_names[$TSA_idx]}.tsr \
      -CApath $DIR_TMP 2> >(grep -v "Using configuration from" >&2)

  rm -rf $DIR_TMP

done
