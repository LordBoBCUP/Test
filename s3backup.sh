#!/bin/bash

###################################################################
#Script Name	  : backup-s3.sh                                                                                           
#Description	  : backups up node to s3 bucket 
#Args           : -r region --short-code <shortRegion>                                                                                         
#Author       	: Alex Massey                                                
#Email         	: alex.massey@augensoftwaregroup.com         
#Notes          : Script assumes folder exists in s3 bucket                                  
###################################################################

########### VARIABLES ###########
S3KEY=
S3SECRET= # pass these in
S3BUCKET= # Name of the s3 bucket  you are backing up to
BLOCKNUMBER= # Latest block number you want to backup to
REGION= # The AWS region e.g us-east-2 where the s3 bucket exists
FILENAME= # The filename of the backup file you are creating

## Logging ##
LOGFILE=backup-s3.sh.log
RETAIN_NUM_LINES=1000

########### FUNCTIONS ###########

function usage()
{
    echo "usage: ./backup-s3.sh [[[-r | --region region ] [-k | --key s3key] [-b | --bucket bucket] [-s | --secret secret] [-n | --blocknumber blocknumber] [-p | -aws-path path]| [-h]]"
}

function printUsageAndExit()
{
    echo "usage: ./backup-s3.sh [[[-r region ] | [-h]]"
    exit 1
}

function logsetup {
    TMP=$(tail -n $RETAIN_NUM_LINES $LOGFILE 2>/dev/null) && echo "${TMP}" > $LOGFILE
    exec > >(tee -a $LOGFILE)
    exec 2>&1
}

function log {
    echo "[$(date --rfc-3339=seconds)]: $*"
}

function putS3
{
  bucket=$1
  path=$2
  file=$(echo "$path" | sed "s/.*\///")
  aws_folder=$3
  resource="/${bucket}/${aws_folder}/${file}"
  contentType="binary/octet-stream"
  dateValue=$(date +"%a, %d %b %Y %T %z")
  stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
  s3Key=xxxxxxxxxxxxxxxxxxxx
  s3Secret=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${S3SECRET} -binary | base64`
  curl -X PUT -T "${path}" \
  -H "Host: ${bucket}.s3.amazonaws.com" \
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${S3KEY}:${signature}" \
  https://${bucket}.s3-ap-southeast-2.amazonaws.com/${aws_folder}/${file}
}

  function validateInput() {
    if [[ -z "$S3KEY" ]];
    then
      printUsageAndExit
    fi

    if [[  -z "$S3SECRET" ]];
    then
      printUsageAndExit
    fi
    if [[  -z "$S3BUCKET" ]];
    then
      printUsageAndExit
    fi

    if [[  -z "$BLOCKNUMBER" ]];
    then
      printUsageAndExit
    fi

    if [[  -z "$AWS_PATH" ]];
    then
      printUsageAndExit
    fi

    if [[  -z "$REGION" ]];
    then
      printUsageAndExit
    fi

    if [[  -z "$FILENAME" ]];
    then
      printUsageAndExit
    fi
  }

function backupChain() {
  FROM=1
  TO=$1
  FILE=$2
  result=$(/usr/local/bin/substrate export-blocks --from $FROM --to $TO /tmp/${FILE})
}

function Main() {
  validateInput
  backupChain 1000 $FILENAME
  putS3 $S3BUCKET /tmp/${FILENAME} $AWS_PATH 
}


########### MAIN ###########
logsetup
log started...

while [ "$1" != "" ]; do
    case $1 in
        -k | --key )            shift
                                S3KEY=$1
                                ;;
        -b | --bucket )         shift
                                S3BUCKET=$1
                                ;;
        -s | --secret )         shift
                                S3SECRET=$1
                                ;;
        -n | --blocknumber )    shift
                                BLOCKNUMBER=$1
                                ;;
        -p | --aws-path )       shift 
                                AWS_PATH=$1
                                ;;
        -r | --region )         shift 
                                REGION=$1
                                ;;
        -f | --filename )       shift 
                                FILENAME=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

Main


log completed backup-s3.sh...
