#!/bin/sh

cd `dirname ${0}`

. ./common.sh

(
started

echo
echo "Rehashing certificates..."
${REHASH} ${CLIENT_PATH}

all_done

) 2>&1 | tee -a ${LOG_PATH}/make_client.log
