package main

import (
	"crypto/rand"
	"crypto/tls"
	"crypto/x509"
	"fmt"
	"github.com/gorilla/mux"
	u "github.com/pprisn/tls_test/utils"
	"io/ioutil"
	"log"
	"net/http"
	//	"os"
	"time"
	"unicode/utf8"
)

func handler(w http.ResponseWriter, r *http.Request) {
	resp := u.Message(true, "Success")
	for i, cert := range r.TLS.PeerCertificates {
		subject := cert.Subject
		issuer := cert.Issuer
		log.Printf(" %d s:/C=%v/ST=%v/L=%v/O=%v/OU=%v/CN=%s  SerialNumber=%s", i, subject.Country, subject.Province,
			subject.Locality, subject.Organization, subject.OrganizationalUnit, subject.CommonName,
			fmt.Sprintf("%X", cert.SerialNumber))
		log.Printf("   i:/C=%v/ST=%v/L=%v/O=%v/OU=%v/CN=%s", issuer.Country, issuer.Province,
			issuer.Locality, issuer.Organization, issuer.OrganizationalUnit, issuer.CommonName)
	}
	log.Print(">>>>>>>>>>>>>>>> State End <<<<<<<<<<<<<<<<")

	var sn, in, sb, sb_CN, str [10]string
	for i, v := range r.TLS.PeerCertificates {
		if i < 10 {
			sn[i] = fmt.Sprintf("%X", v.SerialNumber)
			in[i] = fmt.Sprintf("%v", v.Issuer)
			sb_CN[i] = fmt.Sprintf("%v", v.Subject.CommonName)
			sb[i] = fmt.Sprintf("%+v", v.Subject)
			str[i] = ""
			instr := v.RawSubject
			for len(instr) > 0 {
				r, size := utf8.DecodeRune(instr)
				str[i] += fmt.Sprintf("%c", r)
				instr = instr[size:]
			}
		}
		//regex := regexp.MustCompile("[^\\,]*CN\\=(?P<cn>[^\\,]*)[\\,*]OU\\=(?P<ou>[^\\,]*)[\\,*]O\\=(?P<o>[^\\,]*)")
		//res := regex.FindAllStringSubmatch(sb[i], -1)
		//for i := range res {
		//    //like Java: match.group(1), match.gropu(2), etc
		//		    fmt.Printf("year: %s, month: %s, day: %s\n", res[i][1], res[i][2], res[i][3])
		//}
		//"Subject":"CN=pprisn,OU=UFPS_GOCHS,O=Russan_Post,L=Lipetsk,ST=RU,C=RU"
		//params := getParams(`(?P<Year>\d{4})-(?P<Month>\d{2})-(?P<Day>\d{2})`, `2015-05-27`)
	}
	resp["SerialNumber"] = sn[0]
	resp["Issuer"] = in[0]
	resp["Subject"] = sb[0]
	resp["Subject CN"] = sb_CN[0]
	resp["RawSubject"] = str[0]
	resp["RemoteAddr"] = r.RemoteAddr
	u.Respond(w, resp)
	return
}

func main() {

	//Определим объект маршрутов
	router := mux.NewRouter()
	//Определим обработчики маршрутов
	router.HandleFunc("/", handler)
	//	router.HandleFunc("/api/operator/new", controllers.CreateOperator).Methods("POST")
	//	router.HandleFunc("/api/user/login", controllers.Authenticate).Methods("POST")
	//	router.HandleFunc("/api/contacts/new", controllers.CreateContact).Methods("POST")
	//	router.HandleFunc("/api/me/contacts", controllers.GetContactsFor).Methods("GET") //  user/2/contacts
	//	router.HandleFunc("/api/user/new", controllers.CreateAccount).Methods("POST")
	//	router.HandleFunc("/api/user/login", controllers.Authenticate).Methods("POST")
	//	router.HandleFunc("/api/contacts/new", controllers.CreateContact).Methods("POST")
	//	router.HandleFunc("/api/me/contacts", controllers.GetContactsFor).Methods("GET") //  user/2/contacts

	//Добавим требование запуска проверки middleware для объектов обработки маршрутов !
	//router.Use(app.CertAuthentication) //attach Cert auth middleware

	//Заглушка для не существующего маршрута !
	//	router.NotFoundHandler = app.NotFoundHandler

	// For prod
	//	certPem := []byte(os.Getenv("CERTPEM"))
	//	certKey := []byte(os.Getenv("CERTKEY"))
	//	caCertPem := []byte(os.Getenv("CACERTPEM"))

	// For local test
	certPems, err := ioutil.ReadFile("./ssl/www/server.crt")
	if err != nil {
		log.Fatal(err)
	}

	certKeys, err := ioutil.ReadFile("./ssl/www/server.key")
	if err != nil {
		log.Fatal(err)
	}

	caCertPems, err := ioutil.ReadFile("./ssl/ca/ca.crt")
	if err != nil {
		log.Fatal(err)
	}
	certPem := []byte(certPems)
	certKey := []byte(certKeys)
	caCertPem := []byte(caCertPems)
	///

	/*
	   	certPem := []byte(`-----BEGIN CERTIFICATE----- FAKE
	   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
	   hljZOqA+t4h8
	   -----END CERTIFICATE-----`)
	   	certKey := []byte(`-----BEGIN RSA PRIVATE KEY-----
	   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
	   -----END RSA PRIVATE KEY-----`)

	   	caCertPem := []byte(`-----BEGIN CERTIFICATE-----
	   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
	   yv0sX1DnwKtCW305fgqN2Snhknj9YpQxOQ8riIg=
	   -----END CERTIFICATE-----`)

	*/

	roots := x509.NewCertPool()
	ok := roots.AppendCertsFromPEM(caCertPem)
	if !ok {
		log.Fatal("failed to parse root certificate")
	}

	cert, err := tls.X509KeyPair(certPem, certKey)
	if err != nil {
		log.Fatal(err)
	}
	//	cfg := &tls.Config{Certificates: []tls.Certificate{cert}}
	cfg := &tls.Config{Certificates: []tls.Certificate{cert},
		ClientAuth: tls.RequireAndVerifyClientCert,
		ClientCAs:  roots}
	//RequireAnyClientCert}
	cfg.Rand = rand.Reader

	srv := &http.Server{
		Handler:      router,
		Addr:         "localhost:443",
		TLSConfig:    cfg,
		ReadTimeout:  time.Minute,
		WriteTimeout: time.Minute,
	}
	log.Fatal(srv.ListenAndServeTLS("", ""))
}
