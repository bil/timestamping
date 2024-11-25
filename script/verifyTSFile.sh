#!/bin/bash

set -u

DIR_SCRIPT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $DIR_SCRIPT/TSA.source

FILE_DATA=$1
DIR_CA=$DIR_SCRIPT/../CA

DIR_ORIGIN=$(pwd)

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
  openssl ts -verify -data $FILE_DATA \
      -in tsReply_${TSA_names[$TSA_idx]}.tsr \
      -CApath $DIR_TMP 2> >(grep -v "Using configuration from" >&2)

  rm -rf $DIR_TMP

done
