#! /usr/bin/env bash
set -o nounset
set -o pipefail
set -o errexit

passwdFile=$(mktemp)
echo $AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY > $passwdFile
chmod 400 $passwdFile
mkdir -p $MOUNT_DIR
s3fs $BUCKET_NAME:${BUCKET_DIR:-"/"} $MOUNT_DIR -o url=$BUCKET_URL -o allow_other -o use_path_request_style -o passwd_file=$passwdFile

# [ $? -eq 0 ]
echo "[s3] bucket=$BUCKET_NAME bucket-dir=${BUCKET_DIR:-/} mounted at $MOUNT_DIR"
