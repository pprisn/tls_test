#!/bin/sh

cd `dirname ${0}`

. ./common.sh

if [ ! -f ${_CA_KEY} ]; then
  error "Root key file ${_CA_KEY} not found"
fi

if [ ! -f ${_CA_CRT} ]; then
  error "Root certificate file ${_CA_CRT} not found"
fi

if [ ! -f ${_CA_P12} ]; then
  error "Root PKCS\#12 certificate file ${_CA_P12} not found"
fi

dialog \
--title "Installing root certificate" \
--yesno \
"                    !!! WARNING !!!                         \n"\
"       Replacing existing root key and certificate          \n"\
"         invalidates ALL issued certificates!!!             \n"\
"           Are you REALLY want to continue?                 " 9 63 no 
#9 63 no

if [ $? -ne 0 ]; then
  error "Execution aborted by user"
fi

(

started

echo "Copy root key file"
mv -f ${CA_KEY} ${CA_KEY}.backup
mv -f ${_CA_KEY} ${CA_KEY}
chmod 0600 ${CA_KEY}

echo "Copy root certificate file"
mv -f ${CA_CRT} ${CA_CRT}.backup
mv -f ${_CA_CRT} ${CA_CRT}

echo "Copy root PKCS\#12 certificate file"
mv -f ${CA_P12} ${CA_P12}.backup
mv -f ${_CA_P12} ${CA_P12}

echo "Delete certificate serial file"
mv -f ${CA_SRL} ${CA_SRL}.backup

all_done

) 2>&1 | tee -a ${LOG_PATH}/install-ca.log
