#!/bin/sh
cd `dirname ${0}`
. ./common.sh
#Шаг 1. Создание центра сертификации
(
started
openssl genrsa -out ${_CA_KEY} 4096
chmod 0600 ${_CA_KEY}
##Шаг 1.3. Создаем самоподписанный сертификат.

#openssl req -new -sha256 -x509 -days 1095 -key ${_CA_KEY} -out ${_CA_CRT} \
#        -subj "/C=RU/ST=Lipetsk region/L=UFPS/O=Russianpost/OU=GOCHS/emailAddress=sergey.popurey@russianpost.ru/CN=localhost"

make_dn ${CA_CN}

run_openssl 'Create self-signed root certificate' \
    req -x509 -new -out ${_CA_CRT} -key ${_CA_KEY} -days ${DAYS} -subj ${DN}


run_openssl 'Export P12 certificate' \
    pkcs12 -export -in ${_CA_CRT} -nokeys -out ${_CA_P12} -passout pass:""

run_openssl 'Export text certificate for curl utility' \
    x509 -inform PEM -in ${_CA_CRT} -text -out ${_CA_PEM} -CAcreateserial -CAserial ${CA_SRL}

##Шаг 1.4 Вывод сертификата в текстовом виде
openssl x509 -text -noout -in ${_CA_CRT}

all_done
) 2>&1 | tee -a ${LOG_PATH}/make-ca.log
