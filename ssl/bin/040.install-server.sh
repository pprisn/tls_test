#!/bin/sh

cd `dirname ${0}`

. ./common.sh

if [ ! -f ${_SERVER_KEY} ]; then
  error "Server key file ${_SERVER_KEY} not found"
fi

if [ ! -f ${_SERVER_CRT} ]; then
  error "Server certificate file ${_SERVER_CRT} not found"
fi

if [ ! -f ${_SERVER_P12} ]; then
  error "Server PKCS\#12 certificate file ${_SERVER_P12} not found"
fi

dialog \
--title "Installing web server certificate" \
--yesno \
"           Are you really want to install                  \n"\
"             new web server certificate?                   " 9 63 no

if [ $? -ne 0 ]; then
  error "Execution aborted by user"
fi

(

started

echo "Copy web server key file"
mv -f ${SERVER_KEY} ${SERVER_KEY}.backup
mv -f ${_SERVER_KEY} ${SERVER_KEY}
chmod 0600 ${SERVER_KEY}

echo "Copy web server certificate file"
mv -f ${SERVER_CRT} ${SERVER_CRT}.backup
mv -f ${_SERVER_CRT} ${SERVER_CRT}

echo "Copy web server PKCS\#12 certificate file"
mv -f ${SERVER_P12} ${SERVER_P12}.backup
mv -f ${_SERVER_P12} ${SERVER_P12}

echo "Delete web server certificate request"
rm -f ${_SERVER_REQ}

all_done

) 2>&1 | tee -a ${LOG_PATH}/install-server.log
