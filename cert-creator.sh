#! /bin/bash

_SSL_BASE_DIR=/opt/unblock-proxy/certs
_SSL_PARASED="cert=$_SSL_BASE_DIR/squidCRT.pem key=$_SSL_BASE_DIR/squidPK.key generate-host-certificates=on dynamic_cert_mem_cache_size=4MB options=SINGLE_DH_USE,SINGLE_ECDH_USE tls-dh=$_SSL_BASE_DIR/squidDH.pem"

cat << EOM > ./certs/squid_ssl_ca.conf
[req]
prompt = no
distinguished_name = req_distinguished_name
req_extensions = v3_req

[req_distinguished_name]
C = US
ST = California
L = Los Angeles
O = unblock-proxy
CN = unblock.proxy

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = $(hostname -f)
DNS.2 = www.$(hostname -f)
EOM

##

cat << EOM > ./certs/squid_ssl.conf
[req]
prompt = no
distinguished_name = req_distinguished_name
req_extensions = v3_req

[req_distinguished_name]
C = US
ST = California
L = Los Angeles
O = unblock-proxy
CN = $(hostname -f)

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = $(hostname -f)
DNS.2 = www.$(hostname -f)
EOM

echo "[*] Creating Initial squid-certs"

cd $_SSL_BASE_DIR

## 5Jahre
#openssl req -x509 -newkey rsa:4096 -nodes -keyout squid_key.pem -subj '/CN=$(hostname -f)' -out squid_cert.pem -days 1825

## create CA
echo "[*] Creating and Signing CA. => 10 Years"
sleep 2
openssl genrsa -out squidCA.key 2048
openssl req -x509 -new -config squid_ssl_ca.conf -key squidCA.key -days 3650 -out squidCA.pem

## clientcerts
echo "[*] Setup client certs..."
sleep 3
openssl genrsa -out squidPK.key 2048
#openssl req -new -key squidPK.key -out squid_cert.pem
openssl req -new -config squid_ssl.conf -key squidPK.key -out squidPUB.csr

## signing certs
echo "[*] Signing client certs. => 5 Years"
sleep 3
openssl x509 -req -days 1825 -CA squidCA.pem -CAkey squidCA.key -CAcreateserial -CAserial serial -in squidPUB.csr -out squidCRT.pem

## check for..
echo "[*] Checking Certs.."
sleep 3
openssl verify -verbose -CAfile squidCA.pem squidCRT.pem

## MAKE DER FILE
echo "[*] Creating Diffie-Hellman 4096 bit key"
sleep 2
openssl dhparam -dsaparam -out squidDH.pem 4096

## MAKE DER FILE
echo "[*] Creating DER File for optional importing of CA in Browsers"
sleep 2
openssl x509 -in squidCA.pem -outform DER -out squidCA.der

#templating
echo "[*] Modify the squid template.."
sed "s;_SSL_PARAMS_;$_SSL_PARASED;g" -i ../configs/squid.conf

#exit 0