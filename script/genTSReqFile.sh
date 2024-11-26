#!/bin/bash

set -u

PATH_DATA=$1
DIGEST_SIZE=256

DIR_ORIGIN=$(pwd)
FILE_DIR=$(dirname $PATH_DATA)
FILE_NAME=$(basename $PATH_DATA)

# check for Mac
if [ "$(uname)" = "Darwin" ]; then
    CMD_SHA="shasum -a $DIGEST_SIZE"
else
    CMD_SHA="sha${DIGEST_SIZE}sum"
fi

cd $FILE_DIR
$CMD_SHA "$FILE_NAME" > $DIR_ORIGIN/$FILE_NAME.sha$DIGEST_SIZE

openssl ts -query -data "$FILE_NAME" -sha$DIGEST_SIZE -cert \
    -out $DIR_ORIGIN/tsRequest_$FILE_NAME.tsq 2> >(grep -v "Using configuration from" >&2)
