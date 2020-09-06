#!/bin/bash
#
# Credit: https://github.com/kimble/graylog2-docker
#
# modified by nehlsen / https://github.com/nehlsen
#

USER_PASS="admin:admin"

HOST="localhost:9000"
API_BASE="http://${HOST}/api"
URL_UPCHECK="$API_BASE/"
#URL_SYSTEM_OVERVIEW="$API_BASE/system"
#URL_SERVICE_MANAGER_STATUS="$API_BASE/system/serviceManager"
URL_CONTENT_PACKS="$API_BASE/system/content_packs"

########################################################################################################################

echo "Waiting for Graylog REST-Interface...."

until curl --output /dev/null --silent --head --fail --user ${USER_PASS} ${URL_UPCHECK}; do
    echo '   Waiting some more...'
    sleep 5
done

########################################################################################################################

echo "Graylog REST-Interface seems to be ready"
sleep 1

#echo "---- system ----"
#curl --silent --user ${USER_PASS} ${URL_SYSTEM_OVERVIEW} | jq '.'
#echo "----------------"
#echo ""

#echo "---- service-manager ----"
#curl --silent --user ${USER_PASS} ${URL_SERVICE_MANAGER_STATUS} | jq '.'
#echo "-------------------------"
#echo ""

for LOCAL_FILE in /bootstrap/content-packs/*.json; do
    echo "--------------------------------------------------"

    echo "Uploading content-pack: $LOCAL_FILE";

    CONTENT_PACK_ID=$(jq --raw-output '.id' "$LOCAL_FILE")
    CONTENT_PACK_REVISION=$(jq --raw-output '.rev' "$LOCAL_FILE")
    echo "Content-pack ID: $CONTENT_PACK_ID";
    echo "Content-pack Revision: $CONTENT_PACK_REVISION";
    curl --silent --user ${USER_PASS} -X POST -H "X-Requested-By: bootstrap-script" -H "Content-Type: application/json" -d "@${LOCAL_FILE}" ${URL_CONTENT_PACKS}

    echo "Enabling content-pack..."
    CONTENT_PACK_INSTALL="${URL_CONTENT_PACKS}/${CONTENT_PACK_ID}/${CONTENT_PACK_REVISION}/installations"
    curl --silent --user ${USER_PASS} -X POST -H "X-Requested-By: bootstrap-script" -H "Content-Type: application/json" --data '{"parameters":{},"comment":""}' ${CONTENT_PACK_INSTALL} 2>&1 >/dev/null
done

echo
exit 0
