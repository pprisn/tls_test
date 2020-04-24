
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

#Шаг 3. Создание клиентского сертификата
##Шаг 3.1. Создаем клиентский приватный ключ по тому же принципу.
(
echo "Generate certificate for client ${CLIENT_NAME}"
openssl genrsa -out ${CLIENT_NAME}.key 4096
##Шаг 3.2. Создаем клиентский сертификат.
openssl req -new -key ${CLIENT_NAME}.key -sha256 \
        -out  ${CLIENT_NAME}.csr \
        -subj "/C=RU/ST=Lipetsk region/L=UFPS/O=Russianpost/OU=GOCHS/emailAddress=${CLIENT_EMAIL}/CN=${CLIENT_NAME}"

##Шаг 3.3. Подписываем сертификат ключом kашего центра сертификации.
openssl x509 -req -days 1095 \
        -in  ${CLIENT_NAME}.csr \
        -CA ca.crt \
        -CAkey ca.key \
        -CAcreateserial -CAserial ca.srl \
        -sha256 \
        -out  ${CLIENT_NAME}.crt
#Шаг 4. Создание сертфиката в формате PKCS#12 для браузеров.
openssl pkcs12 -export -in  ${CLIENT_NAME}.crt -inkey  ${CLIENT_NAME}.key -name "Certificate for GOCHS" -out \
        ${CLIENT_NAME}.p12 -passout pass:""

#Шаг 5. Просмотр содержимого сертификата
openssl x509 -text -noout -in  ${CLIENT_NAME}.crt -issuer -subject -dates -fingerprint -serial

) 2>&1 | tee -a make-client.log
