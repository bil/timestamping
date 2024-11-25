#!/bin/bash

# standalone example script performing trusted timestamping on a single data file
# requirements: openssl (3.0+), curl, jq, bash (3+), sha256sum/shasum, base64

# exit on error
set -e

# specify file to timestamp
FILE_DATA=rand_241109/random1.dat
FILE_DATA_NAME=$(basename $FILE_DATA)

PATH=$PATH:../script

# clearing any prior files
rm -f rand*.sha*
rm -f tsRe*.ts*
rm -f timestamps*.json

echo "Hashing data file and generating timestamp request..."
genTSReqFile.sh $FILE_DATA
printf "Timestamp request generated.\n\n"

echo "Sending timestamp request to timestamp authority servers and receiving reply..."
stampReq.sh tsRequest_$FILE_DATA_NAME.tsq
printf "Timestamp replies received\n\n"

echo "Verifying timestamp replies..."
verifyTSFile.sh $FILE_DATA
printf "Verification complete, timestamps verified if all output reads: \"Verification: OK\"\n\n"

echo "Building timestamps JSON..."
packTSjson.sh ./
printf "Timestamps JSON built\n\n"

echo "Deleting checksum and all timestamp reply files..."
rm tsReply*.tsr
rm $FILE_DATA_NAME.sha*
printf "Deleted\n\n"

echo "Unpacking JSON to restore checksum and all timestamp reply files..."
unpackTSjson.sh timestamps_$FILE_DATA_NAME.json
printf "Unpacked\n\n"
