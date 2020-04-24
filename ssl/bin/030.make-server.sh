#!/bin/sh

cd `dirname ${0}`

. ./common.sh

(
started
#Шаг 2. Создание сертификата сервера
##Шаг 2.1 Создаем приватный ключ для веб-сервера.
#openssl genrsa -out server.key 4096

run_openssl 'Create server private key' \
    genrsa -out ${_SERVER_KEY} 4096

chmod 0600 ${_SERVER_KEY}


##Шаг 2.2. Создаем запрос на сертификат для веб-сервера.

#DN="/CN=localhost"

EMAIL='sergey.popurey@russianpost.ru'
make_dne ${SERVER_CN} ${EMAIL}
run_openssl 'Create server certificate request' \
    req -new -out ${_SERVER_REQ} -key ${_SERVER_KEY} -subj ${DN}


# Вывести на экран структуру секретного ключа
#openssl rsa -in server.key -noout -text
#Шаг 2.3. Подписываем сертификат веб-сервера ключом нашего центра сертификации.
run_openssl 'Create server certificate from certificate request' \
        x509 -req -days 3650 \
        -in ${_SERVER_REQ} \
        -CA ${CA_CRT} \
        -CAkey ${CA_KEY} \
        -CAcreateserial -CAserial ${CA_SRL} \
        -out ${_SERVER_CRT}

#Шаг 2.4 Экспорт сертификата
run_openssl 'Export PKCS\#12 certificate' \
    pkcs12 -export -in ${_SERVER_CRT} -nokeys -out ${_SERVER_P12} -passout pass:""

#Шаг 2.5 Вывод содержимого сертификата
run_openssl 'Show generated server certificate info' \
    x509 -in ${_SERVER_CRT} -noout -issuer -subject -dates -fingerprint

all_done
) 2>&1 | tee -a ${LOG_PATH}/make_server.log
