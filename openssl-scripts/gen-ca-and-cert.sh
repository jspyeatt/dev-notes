#!/bin/bash

if [ $# -eq 0 ]
then
   echo "ERROR: You need to specify a hostname or ip address"
   exit 1
fi

certDir=/tmp/certs
mkdir -p $certDir
rm ${certDir}/* 2>/dev/null

rootKey=${certDir}/root-private.key
rootCert=${certDir}/root-ca.pem

childKey=${certDir}/child-private.key
childCSR=${certDir}/child.csr

publicPEM=${certDir}/child-cert.pem

passwordFile=${certDir}/passphrase.txt

host=$1
certSubject="/C=US/ST=Wisconsin/L=Madison/O=Singlewire/CN=${host}"
caSubject="/C=US/ST=Wisconsin/L=Madison/O=Singlewire"

openssl rand -base64 48 > ${passwordFile}

echo "generating root CA"
openssl req -new -x509 -keyout ${rootKey} -out ${rootCert} -subj "${caSubject}" -passout file:${passwordFile}
if [ $? -ne 0 ]
then
   echo "ERROR: Unable to create root CA"
   exit 1
fi

echo "generating child key"
openssl genrsa -passout file:${passwordFile} -out ${childKey} 2048 
if [ $? -ne 0 ]
then
   echo "ERROR: Unable to create private child certificate"
   exit 1
fi

echo "generating CSR for child"
openssl req -new -key ${childKey} -out ${childCSR} -subj "${certSubject}"
if [ $? -ne 0 ]
then
   echo "ERROR: Unable to create child CSR"
   exit 1
fi

echo "sign the child certificate"
openssl x509 -req -days 36500 -in ${childCSR} -CA ${rootCert} -CAkey ${rootKey} -CAcreateserial -out ${publicPEM} -passin file:${passwordFile}
if [ $? -ne 0 ]
then
   echo "ERROR: Unable to sign child certificate"
   exit 1
fi

echo "verify the child certificate"
#openssl verify -CAform PEM -verbose ${publicPEM}
openssl x509 -in ${publicPEM} -noout
if [ $? -ne 0 ]
then
   echo "ERROR: Unable to verify signed child"
   exit 1
fi

echo ""
echo "certificate verified"
echo ""
echo "root CA private key ${rootKey}"
echo "root CA public cert ${rootCert}"
echo "child certificate   ${publicPEM}"
