#!/bin/bash

set -u
set -e

TSR=$1
FILE_NAME=$(basename $TSR .tsr)

openssl ts    -reply -in "$FILE_NAME".tsr -token_out -out "$FILE_NAME".tk
openssl pkcs7 -inform DER -in "$FILE_NAME".tk -print_certs -outform PEM -out "$FILE_NAME".pem
rm "$FILE_NAME".tk
