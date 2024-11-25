#!/bin/bash

# requirements: jq, base64

set -e
set -u

DIR_TS=$1

FORMAT="TIMESTAMPS_BUNDLE"
VERSION=0.1.0

DIGEST_SIZE=256

DIR_SCRIPT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $DIR_SCRIPT/TSA.source

FILE_HASH=$(find $DIR_TS -name "*.sha$DIGEST_SIZE" -exec basename {} .sha$DIGEST_SIZE \;)

JSON=$(echo "{}" | jq ".format = \"$FORMAT\"")
JSON=$(echo "$JSON" | jq ".version = \"$VERSION\"")

JSON=$(echo "$JSON" | jq ".hashfile = {\"filename\" : \"$FILE_HASH.sha$DIGEST_SIZE\", \"algorithm\" : \"SHA$DIGEST_SIZE\", \"hash\" : \"$(base64 -w 0 < <(<$DIR_TS/$FILE_HASH.sha$DIGEST_SIZE) )\"} ")

for TSA_idx in $(seq 0 $((${#TSA_names[@]}-1)) ); do
    JSON=$(echo "$JSON" | jq ".timestamps += [{ \"authority\" : \"${TSA_names[$TSA_idx]}\", \"url\" : \"${TSA_urls[$TSA_idx]}\", \"reply\" : \"$(base64 -w 0 < <(<$DIR_TS/tsReply_${TSA_names[$TSA_idx]}.tsr) )\", \"CA\" : \"$(base64 -w 0 < <(<$DIR_SCRIPT/../CA/${TSA_names[$TSA_idx]}CA.pem) )\"}]" )
done

echo $JSON > timestamps_$FILE_HASH.json
