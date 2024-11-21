#!/bin/bash

# requirements: jq, base64

set -e
#set -x
set -u

FILE_TS=$1

FILE_HASH_NAME=$(jq -r '.hashfile.filename' < $FILE_TS)
FILE_HASH_DATA=$(jq -r '.hashfile.hash' < $FILE_TS)

if [ -n "$FILE_HASH_NAME" ]; then
    base64 -d < <(echo $FILE_HASH_DATA) > $FILE_HASH_NAME
fi

NUM_TS=$(jq '.timestamps | length' < $FILE_TS)

for TS_IDX in $(seq 0 $(($NUM_TS - 1)) ); do
    TSA=$(jq -r ".timestamps[$TS_IDX].authority" < $FILE_TS)
    TSR=$(jq -r ".timestamps[$TS_IDX].reply" < $FILE_TS)

    base64 -d < <(echo $TSR) > tsReply_$TSA.tsr
done
