#!/bin/bash

# standalone example script performing trusted timestamping on a single data file
# requirements: openssl (3.0+), curl, jq, bash (3+), coreutils

# exit on error
set -e

# specify example file to timestamp
PATH_DATA=rand_241109/random1.dat

if [ "$1" == 'DIR' ]; then
    # timestamp directory contents
    PATH_DATA=rand_241109
fi

PATH_DATA_NAME=$(basename $PATH_DATA)
PATH=$PATH:../trustedtimestamping/usr/local/bin

# clearing any prior files
rm -f *.sha*
rm -f tsRe*.ts*
rm -f tsCRL*.crl
rm -f timestamps*.json

echo "Hashing data file and generating timestamp request..."
ttsGenReq $PATH_DATA
printf "Timestamp request generated.\n\n"

echo "Sending timestamp request to timestamp authority servers and receiving reply..."
ttsStamp tsRequest_$PATH_DATA_NAME.tsq
printf "Timestamp replies received\n\n"

echo "Verifying timestamp replies..."
ttsVerify $PATH_DATA
printf "Verification complete, timestamps verified if all output reads: \"Verification: OK\"\n\n"

echo "Building timestamps JSON..."
ttsPackJSON ./
printf "Timestamps JSON built\n\n"

echo "Deleting checksum and all timestamp reply and CRL files..."
rm *.sha*
rm tsReply*.tsr
rm tsCRL*.crl
printf "Deleted\n\n"

echo "Unpacking JSON to restore checksum and all timestamp reply files..."
ttsUnpackJSON timestamps_$PATH_DATA_NAME.json
printf "Unpacked\n\n"
