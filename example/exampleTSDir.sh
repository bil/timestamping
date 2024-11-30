#!/bin/bash

# standalone example script performing trusted timestamping on a directory of data
# requirements: openssl (3.0+), curl, jq, bash (3+), sha256sum/shasum, base64, find/cut/tee

# exit on error
set -e

# specify file to timestamp
DIR_DATA=rand_241109

PATH=$PATH:../trustedtimestamping/usr/local/bin

# clearing any prior files
rm -f rand*.sha*
rm -f tsRe*.ts*
rm -f tsCRL*.crl
rm -f timestamps*.json

echo "Hashing data directory and generating timestamp request..."
ttsGenReqDir $DIR_DATA
printf "Timestamp request generated.\n\n"

echo "Sending timestamp request to timestamp authority servers and receiving reply..."
ttsStamp tsRequest_$DIR_DATA.tsq
printf "Timestamp replies received\n\n"

echo "Verifying timestamp replies..."
ttsVerifyDir $DIR_DATA
printf "Timestamps verified if all output reads: \"Verification: OK\"\n\n"

echo "Building timestamps JSON..."
ttsPackJSON ./
printf "Timestamps JSON built\n\n"

echo "Deleting checksum and all timestamp reply files..."
rm tsReply*.tsr
rm tsCRL*.crl
rm $DIR_DATA.sha*
printf "Deleted\n\n"

echo "Unpacking JSON to restore checksum and all timestamp reply files..."
ttsUnpackJSON timestamps_$DIR_DATA.json
printf "Unpacked\n\n"
