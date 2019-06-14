  #!/bin/bash 

  /usr/local/bin/substrate export-blocks -d /data --chain /data/chainspec.json /data/backup.bin

  bucket="mx-ap-southeast-2-p-cluster-1"
  path="/data/backup.bin"
  file=$(echo "$path" | sed "s/.*\///")
  aws_folder="storage-test3"
  resource="/${bucket}/${aws_folder}/${file}"
  contentType="binary/octet-stream"
  dateValue=$(date +"%a, %d %b %Y %T %z")
  stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
  signature=`echo -en ${stringToSign} | openssl sha1 -hmac M1dQ/1is8Nyb2DIF4S1adzo5tIkXI76uQzBkQzWF -binary | base64`
  curl -X PUT -T "${path}" \
  -H "Host: ${bucket}.s3.amazonaws.com" \
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS AKIA5EB3BYBV7TQ3HBH6:${signature}" \
  https://${bucket}.s3-ap-southeast-2.amazonaws.com/${aws_folder}/${file}
