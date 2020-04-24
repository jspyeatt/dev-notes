#!/bin/bash

if [ $# -lt 1 ]
then
  echo "ERROR: You must specify the directory of the .cnf files. It should be in the root of the gitlab repo."
  exit 1
fi

configDir=$1

# This will create all the artifacts of an intermediate CA and put them in the directory /tmp/certs/intermediateCA
rootDir='/tmp/certs/intermediateCA'
rm -rf $rootDir
mkdir -p $rootDir
cd $rootDir
mkdir certs crl newcerts private csr
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber

cd $rootDir

# create the private key - using RSA instead of AES256
openssl genrsa -aes256 -out ${rootDir}/private/intermediate.key.pem -passout pass:changeMe 4096
if [ $? -ne 0 ];then echo "ERROR creating private key"; exit 1; fi

# create csr
openssl req -config ${configDir}/openssl-intermediate.cnf -new -sha256 -key ${rootDir}/private/intermediate.key.pem -out ${rootDir}/csr/intermediate.csr.pem -passin pass:changeMe -subj "/C=US/ST=Wisconsin/L=Madison/O=Pyeatt/OU=Dev/CN=Intermediate CA"
if [ $? -ne 0 ];then echo "ERROR creating intermediate signing request"; exit 1; fi

# create intermediate certificate
openssl ca -batch -config ${configDir}/openssl-root.cnf -extensions v3_intermediate_ca -days 3650 -notext -md sha256 -in ${rootDir}/csr/intermediate.csr.pem -out ${rootDir}/certs/intermediate.cert.pem -passin pass:changeMe
if [ $? -ne 0 ];then echo "ERROR creating intermediate certificate"; exit 1; fi

# verify the intermediate certificate
openssl x509 -text -in ${rootDir}/certs/intermediate.cert.pem
if [ $? -ne 0 ];then echo "ERROR verifying certificate"; exit 1; fi

echo ""
echo "***********************************************************************"
echo "Intermediate Certificate verified"
echo "public certificate      = ${rootDir}/certs/intermediate.cert.pem"
echo "private key             = ${rootDir}/private/intermediate.key.pem"
echo "***********************************************************************"

