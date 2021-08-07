#! /usr/bin/env bash

echo $AWSACCESSKEYID:$AWSSECRETACCESSKEY | sed 's/\s//' > password
chmod 600 password
mkdir /data
s3fs $BUCKET_NAME:/$BUCKET_FOLDER /data -o url=https://$BUCKET_REGION -o use_path_request_style -o passwd_file=/password
sleep 10
