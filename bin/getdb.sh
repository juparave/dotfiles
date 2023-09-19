#!/bin/bash

# This script retrieves a copy of the remote MySQL DB and copies it locally.

# Usage: ./getdb.sh <remote_user> <remote_host> <remote_db_user> <remote_db_password> <local_db_user> <local_db_password> <local_db_name>

REMOTE_USER="$1"
REMOTE_HOST="$2"
REMOTE_DB_USER="$3"
REMOTE_DB_PASS="$4"
DATABASE_NAME="$5"
LOCAL_DB_USER="$6"
LOCAL_DB_PASS="$7"

# Remove existing local backup if it exists
rm -f chofero.sql.bz2

# Dump the remote database and compress it
ssh "$REMOTE_USER@$REMOTE_HOST" "mysqldump -u $REMOTE_DB_USER -p$REMOTE_DB_PASS --opt $DATABASE_NAME" | bzip2 > ${DATABASE_NAME}.sql.bz2

echo "Remote database copied and compressed."

# If updatedb.sh is available, run the update process
if [ -x "./updatedb.sh" ]; then
    ./updatedb.sh "$LOCAL_DB_USER" "$LOCAL_DB_PASS" "$DATABASE_NAME"
fi

