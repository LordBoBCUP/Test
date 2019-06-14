#!/bin/bash 
mkdir /tmp/mx
# Get Chainspec
curl https://raw.githubusercontent.com/LordBoBCUP/Test/master/chainspec.json --output /tmp/mx/chainspec.json
curl https://raw.githubusercontent.com/LordBoBCUP/Test/master/backup.bin --output /tmp/mx/chainspec.json

# Run Backup
    /usr/local/bin/substrate import-blocks -d /tmp/mx --chain /tmp/mx/chainspec.json /tmp/mx/backup.bin
