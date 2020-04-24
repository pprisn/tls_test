#!/bin/sh

cd `dirname ${0}`


#
# Remove incorrect characters
#
_CLIENT_NAME=${1}

CLIENT_EMAIL=${2}

CLIENT_NAME=${_CLIENT_NAME}
CLIENT_NAME=`echo ${CLIENT_NAME} | sed 's/;//g'`
CLIENT_NAME=`echo ${CLIENT_NAME} | sed 's/ //g'`
CLIENT_NAME=`echo ${CLIENT_NAME} | sed 's/\.//g'`
CLIENT_NAME=`echo ${CLIENT_NAME} | sed 's/\///g'`
CLIENT_NAME=`echo ${CLIENT_NAME} | sed 's/\\\\//g'`

if [ -z ${CLIENT_NAME} ] || [ -z ${CLIENT_EMAIL} ] ; then
  echo "Usage: ${0} <client_name> <client_email>"
  exit 1
fi

if [ "${_CLIENT_NAME}" != "${CLIENT_NAME}" ]; then
  error "Incorrect client name"
  exit 1
fi

. ./common.sh


#Шаг 3. Создание клиентского сертификата
##Шаг 3.1. Создаем клиентский приватный ключ по тому же принципу.
(
started

echo "Generate certificate for client ${CLIENT_NAME}"
#openssl genrsa -out ${CLIENT_NAME}.key 4096

run_openssl 'Create client private key' \
    genrsa -out ${_CLIENT_KEY} 4096

##Шаг 3.2. Создаем запрос для создания клиентского сертификата.

make_dne ${CLIENT_NAME} ${CLIENT_EMAIL}
 
#DN="/C=RU/ST=Lipetsk region/L=UFPS/O=Russianpost/OU=GOCHS/emailAddress=${CLIENT_EMAIL}/CN=${CLIENT_NAME}"

#DN="/O=Russianpost/OU=GOCHS/EMAILADDRESS=${CLIENT_EMAIL}/CN=${CLIENT_NAME}"

run_openssl 'Create client certificate request' \
    req -new -out ${_CLIENT_REQ} -key ${_CLIENT_KEY} -subj ${DN}

##Шаг 3.3. Подписываем сертификат ключом kашего центра сертификации.
run_openssl 'Create client certificate from certificate request' \
    x509 -req -in ${_CLIENT_REQ} \
    -CA ${CA_CRT} -CAkey ${CA_KEY} \
    -CAcreateserial -CAserial ${CA_SRL} \
    -out ${_CLIENT_CRT} -days ${DAYS}


#Шаг 4. Создание сертфиката в формате PKCS#12 для браузеров.
run_openssl 'Export PKCS\#12 certificate' \
    pkcs12 -export -in ${_CLIENT_CRT} -inkey ${_CLIENT_KEY} -out ${_CLIENT_P12} -passout pass:""


#Шаг 5.Просмотр содержимого сертификата
run_openssl 'Show generated client certificate info' \
    x509 -in ${_CLIENT_CRT} -noout -issuer -subject -dates -fingerprint -serial

if [ -f ${CLIENT_CRT} ]; then
  mv -f ${CLIENT_CRT} ${CLIENT_CRT}.backup
fi
mv -f ${_CLIENT_CRT} ${CLIENT_CRT}

if [ -f ${CLIENT_P12} ]; then
  mv -f ${CLIENT_P12} ${CLIENT_P12}.backup
fi
mv -f ${_CLIENT_P12} ${CLIENT_P12}

if [ -f ${CLIENT_KEY} ]; then
  mv -f ${CLIENT_KEY} ${CLIENT_KEY}.backup
fi
mv -f ${_CLIENT_KEY} ${CLIENT_KEY}

rm -f ${_CLIENT_REQ}
all_done
) 2>&1 | tee -a ${LOG_PATH}/make_client.log
