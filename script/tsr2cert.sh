#!/bin/bash

set -u
set -e

TSR=$1
FILE_NAME=$(basename $TSR .tsr)

openssl ts    -reply -in $TSR -token_out -out "$FILE_NAME".tk 2> >(grep -v "Using configuration from" >&2)
openssl pkcs7 -inform DER -in "$FILE_NAME".tk -print_certs -outform PEM -out "$FILE_NAME".pem
rm "$FILE_NAME".tk
