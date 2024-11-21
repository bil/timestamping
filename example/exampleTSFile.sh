#!/bin/bash

# standalone example script performing trusted timestamping on a single data file
# requirements: openssl (3.0+), curl, bash (3+), sha256sum/shasum

# exit on error
set -e

# specify file to timestamp
FILE_DATA=rand_241109/random1.dat

PATH=$PATH:../script

echo "Hashing data file and generating timestamp request..."
genTSReqFile.sh $FILE_DATA
printf "Timestamp request generated.\n\n"

echo "Sending timestamp request to timestamp authority servers and receiving reply..."
stampReq.sh timestampRequest.tsq
printf "Timestamp replies received\n\n"

echo "Verifying timestamp replies..."
verifyTSFile.sh $FILE_DATA
printf "Timestamps verified if all output reads: \"Verification: OK\"\n\n"
