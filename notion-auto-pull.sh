#!/bin/bash

# See: https://joel.wiki/automatic-notion-backup-with-github
NOTION_TOKEN="" 
NOTION_SPACE_ID=""

# Variables.
JQ_BIN="/usr/bin/jq" # https://stedolan.github.io/jq/
NOTION_BACKUP_PATH="/home/user/backups/" # Path where the backup should be stored.
NOTION_EXPORT_FORMAT="markdown" # Can either be html or markdown.
NOTION_ZIP="Notion-Backup-$(date +%Y-%m-%d)-${NOTION_EXPORT_FORMAT}.zip" # Filename of the backup.
TIMEOUT=300 # Timeout in seconds.

# Check if the backup destination or file exists.
NOTION_BACKUP_PATH="${NOTION_BACKUP_PATH%/}/"
if [ ! -d "${NOTION_BACKUP_PATH%/}/" ]; then
	echo "${NOTION_BACKUP_PATH%/}/ does not exist. Aborting." && exit 255
fi
cd "${NOTION_BACKUP_PATH%/}/" || exit

if [ -f "${NOTION_BACKUP_PATH%/}/${NOTION_ZIP}" ]; then
    echo "${NOTION_ZIP} already exists in ${NOTION_BACKUP_PATH%/}/. Aborting." && exit 255
fi

# Start the Notion export.
DATA="{\"task\":{\"eventName\":\"exportSpace\",\"request\":{\"spaceId\":\"${NOTION_SPACE_ID}\",\"exportOptions\":{\"exportType\":\"${NOTION_EXPORT_FORMAT}\",\"timeZone\":\"Europe/Berlin\",\"locale\":\"en\",\"includeContents\":\"everything\",\"flattenExportFiletree\":false}}}}"
EXPORT=$(curl https://www.notion.so/api/v3/enqueueTask -H 'Content-Type: application/json; charset=utf-8' -b "token_v2=${NOTION_TOKEN}" --data "${DATA}" -o - -f -s -S)

# If this fails, the token is probably wrong, but check the HTTP error. 401 is forbidden, which is a token issue.
if [ ! "${EXPORT}" ]
then
	exit $?
fi

# Save time to check if the script or export hangs.
BEGIN=$(date +%s)

# Wait for the export to be ready.
while true
do
	# Get updates from the task.
	EXPORT_ID=$(echo "${EXPORT}" | ${JQ_BIN} -r '.taskId')
	DATA="{\"taskIds\":[\"${EXPORT_ID}\"]}"
	TASK=$(curl https://www.notion.so/api/v3/getTasks -H 'Content-Type: application/json; charset=utf-8' -b "token_v2=${NOTION_TOKEN}" --data "${DATA}" -o - -f -s -S)

	if [ "$(echo "${TASK}" | ${JQ_BIN} '.results[0].state')" = '"success"' ]
	then
		DOWNLOAD_URL=$(echo "${TASK}" | ${JQ_BIN} -r '.results[0].status.exportURL')
		curl -L -o ./"${NOTION_ZIP}" -f -s -S "${DOWNLOAD_URL}"
		exit $?
	fi

	# If it took longer than the defined timeout, something probably failed.
	if [ "$(date +%s)" -gt $((BEGIN + TIMEOUT)) ]
	then
		echo "Tried to export for ${TIMEOUT} seconds, but Notion did not provide the download. Aborting."
		exit 255
	fi

	sleep $((5+RANDOM % 5))
done
