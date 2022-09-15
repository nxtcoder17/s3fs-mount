#! /usr/bin/env bash
set -o nounset
set -o pipefail
set -o errexit

LOCK_FILE=$1

passwdFile=$(mktemp)
echo $AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY > $passwdFile
chmod 400 $passwdFile
mkdir -p $MOUNT_DIR
# chown -R 1000:1000 $MOUNT_DIR
echo "[s3] trying to mount bucket=$BUCKET_NAME bucket-dir=${BUCKET_DIR:-/} at $MOUNT_DIR"
# s3fs $BUCKET_NAME:${BUCKET_DIR:-"/"} $MOUNT_DIR -o url=$BUCKET_URL -o allow_other -o use_path_request_style -o passwd_file=$passwdFile -f
s3fs $BUCKET_NAME:${BUCKET_DIR:-"/"} $MOUNT_DIR -o url=$BUCKET_URL -o allow_other -o use_path_request_style -o passwd_file=$passwdFile -f &

sleep 2
touch $LOCK_FILE

while [ -f $LOCK_FILE ]
do
  sleep 2
done

rm $LOCK_FILE || exit 0
exit 0
