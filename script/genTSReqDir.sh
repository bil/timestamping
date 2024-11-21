#!/bin/bash

set -e
set -u

DIR_ORIGIN=$(pwd)

DIR_DATA=$1
DIGEST_SIZE=256

# check for Mac
if [ "$(uname)" = "Darwin" ]; then
    CMD_SHA="shasum -a $DIGEST_SIZE"
else
    CMD_SHA="sha${DIGEST_SIZE}sum"
fi

cd $DIR_DATA
DIGEST_DATA=$(find ./ -type f -exec $CMD_SHA {} \; | tee $DIR_ORIGIN/${DIR_DATA}.sha${DIGEST_SIZE}sum | $CMD_SHA | cut -c 1-$(($DIGEST_SIZE/4)) )

openssl ts -query -digest $DIGEST_DATA -sha$DIGEST_SIZE -cert -no_nonce -out $DIR_ORIGIN/timestampRequest.tsq
