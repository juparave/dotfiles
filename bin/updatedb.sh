#!/bin/bash

# This script updates the local database.

# Usage: ./updatedb.sh <remote user> <remote host> <local_db_user> <local_db_password> <database_name>

REMOTE_USER="$1"
REMOTE_HOST="$2"
LOCAL_DB_USER="$3"
LOCAL_DB_PASS="$4"
DATABASE_NAME="$5"

# Retrieve the remote compressed database
scp $REMOTE_USER@$REMOTE_HOST:~/$DATABASE_NAME.sql.bz2 .

# Decompress the database
bunzip2 -vdf $DATABASE_NAME.sql.bz2

# Import the database into the local MySQL server
mysql -u "$LOCAL_DB_USER" -p"$LOCAL_DB_PASS" $DATABASE_NAME < $DATABASE_NAME.sql

echo "Local database updated."

