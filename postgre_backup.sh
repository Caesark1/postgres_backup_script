#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <path-to-save-backup> <db-name> <db-user> <docker-container-name>"
    exit 1
fi

# Assigning arguments to variables
BACKUP_PATH=$1
DB_NAME=$2
DB_USER=$3
DOCKER_CONTAINER_NAME=$4

# Check if the backup path exists
if [ ! -d "$BACKUP_PATH" ]; then
    echo "Backup path does not exist: $BACKUP_PATH"
    exit 1
fi

# Current date for the backup file name
# It’s important to note that the date command and its -d option may behave differently in different Unix-like systems.
# For example, on a MacOS system, you would use -v-1w to get 1 week ago date:
SEVEN_DAYS_AGO="$(date -v-1w +'%s')"
# SEVEN_DAYS_AGO=$(date -d "7 days ago" +"%s")
CURRENT_DATE=$(date +"%Y_%m_%d")
DUMP_FILE="${BACKUP_PATH}/dump_${CURRENT_DATE}.sql"

# Perform the database backup
docker exec $DOCKER_CONTAINER_NAME pg_dump -U $DB_USER -d $DB_NAME > $DUMP_FILE

# Delete backup files older than 7 days in the specified backup path
find $BACKUP_PATH -maxdepth 1 -name "dump_*.sql" | while read FILE; do
    FILE_DATE=$(echo $FILE | grep -oP '(?<=dump_)\d{4}_\d{2}_\d{2}')
    FILE_TIMESTAMP=$(date -d $FILE_DATE +"%s")
    echo $FILE_TIMESTAMP

    # if [ $FILE_TIMESTAMP -lt $SEVEN_DAYS_AGO ]; then
    #     rm $FILE
    # fi
done

echo "Backup completed. Old backups cleaned."
