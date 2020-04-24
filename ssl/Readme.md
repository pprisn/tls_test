#Шаг 1. Создание центра сертификации

Чтобы приступить к работе сперва необходимо настроить центр сертификации (CA), это довольно просто. Если на сервере установлен OpenSSL, то СА по умолчанию настроен и готов к работе. Теперь создадим свой собственный доверенный сертифика, он необходим для подписи клиентских сертификатов и для их проверки при авторизации клиента веб-сервером.
##Шаг 1.2. Создаем приватный ключ центра сертификации.

openssl genrsa -out ca.key 4096
 
##Шаг 1.3. Создаем самоподписанный сертификат.

openssl req -new -sha256 -x509 -days 1095 -key ca.key -out ca.crt

#Шаг 2. Создание сертификата сервера
##Шаг 2.1 Создаем приватный ключ для веб-сервера.

openssl genrsa -out server.key 4096

##Шаг 2.2. Создаем сертификат для веб-сервера.

openssl req -new -key server.key -sha256 -out server.csr

##Шаг 2.3. Подписываем сертификат веб-сервера нашим центром сертификации.

openssl x509 -req -days 1095 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 0x`openssl rand 16 -hex` -sha256 -out server.pem

#Шаг 3. Создание клиентского сертификата
##Шаг 3.1. Создаем клиентский приватный ключ по тому же принципу.

openssl genrsa -out client.key 4096

##Шаг 3.2. Создаем клиентский сертификат.

openssl req -new -key client.key -sha256 -out client.csr

##Шаг 3.3. Подписываем сертификат нашим центром сертификации.

openssl x509 -req -days 1095 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 0x`openssl rand 16 -hex` -sha256 -out client.pem

#Шаг 4. Создание сертфиката в формате PKCS#12 для браузеров.

openssl pkcs12 -export -in client.pem -inkey client.key -name "Sub-domain certificate for some name" -out client.p12

#Вариант кода на GO по проверке сертификата клиента на стороне сервера
func renewCert(w http.ResponseWriter, r *http.Request) {

  if r.TLS != nil && len(r.TLS.PeerCertificates) > 0 {
    cn := strings.ToLower(r.TLS.PeerCertificates[0].Subject.CommonName)
    fmt.Println("CN: %s", cn)
  }

}

#Код на GO для настройки сервера по запросу SSL клиента
// Load my SSL key and certificate
cert, err := tls.LoadX509KeyPair(settings.MyCertificateFile, settings.MyKeyFile)
checkError(err, "LoadX509KeyPair")

// Load the CA certificate for client certificate validation
capool := x509.NewCertPool()
cacert, err := ioutil.ReadFile(settings.CAKeyFile)
checkError(err, "loadCACert")
capool.AppendCertsFromPEM(cacert)

// Prepare server configuration
config := tls.Config{Certificates: []tls.Certificate{cert}, ClientCAs: capool, ClientAuth: tls.RequireAndVerifyClientCert}
config.NextProtos = []string{"http/1.1"}
config.Rand = rand.Reader

