#!/bin/sh

cd `dirname ${0}`

#
# Remove incorrect characters
#
_CLIENT_NAME=${1}

CLIENT_NAME=${_CLIENT_NAME}
CLIENT_NAME=`echo ${CLIENT_NAME} | sed 's/;//g'`
CLIENT_NAME=`echo ${CLIENT_NAME} | sed 's/ //g'`
CLIENT_NAME=`echo ${CLIENT_NAME} | sed 's/\.//g'`
CLIENT_NAME=`echo ${CLIENT_NAME} | sed 's/\///g'`
CLIENT_NAME=`echo ${CLIENT_NAME} | sed 's/\\\\//g'`

if [ -z ${CLIENT_NAME} ]; then
  echo "Usage: ${0} <client_name>"
  exit 1
fi

if [ "${_CLIENT_NAME}" != "${CLIENT_NAME}" ]; then
  error "Incorrect client name"
  exit 1
fi

. ./common.sh

(
started

echo "Generate certificate for client ${CLIENT_NAME}"

run_openssl 'Create client private key' \
    genrsa -out ${_CLIENT_KEY} 1024

make_dn ${CLIENT_NAME}
run_openssl 'Create client certificate request' \
    req -new -out ${_CLIENT_REQ} -key ${_CLIENT_KEY} -subj ${DN}

run_openssl 'Create client certificate from certificate request' \
    x509 -req -in ${_CLIENT_REQ} -CA ${CA_CRT} -CAkey ${CA_KEY} -CAcreateserial -CAserial ${CA_SRL} -out ${_CLIENT_CRT} -days ${DAYS}

run_openssl 'Export PKCS\#12 certificate' \
    pkcs12 -export -in ${_CLIENT_CRT} -inkey ${_CLIENT_KEY} -out ${_CLIENT_P12} -passout pass:""

run_openssl 'Show generated client certificate info' \
    x509 -in ${_CLIENT_CRT} -noout -issuer -subject -fingerprint -serial

if [ -f ${CLIENT_CRT} ]; then
  mv -f ${CLIENT_CRT} ${CLIENT_CRT}.backup
fi
mv -f ${_CLIENT_CRT} ${CLIENT_CRT}

if [ -f ${CLIENT_P12} ]; then
  mv -f ${CLIENT_P12} ${CLIENT_P12}.backup
fi
mv -f ${_CLIENT_P12} ${CLIENT_P12}

rm -f ${_CLIENT_KEY}
rm -f ${_CLIENT_REQ}

echo
echo "Rehashing certificates..."
${REHASH} ${CLIENT_PATH}

all_done

) 2>&1 | tee -a ${LOG_PATH}/make_client.log
