#!/bin/bash

# this script is based entirely on https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html

# also useful https://www.spiderbird.com/2015/08/02/openssl-s_client-to-verify-you-installed-your-certificate-properly-and-list-of-return-codes/

if [ $# -lt 1 ]
then
  echo "ERROR: You must specify the location of your openssl-root.cnf file. It should be in the root of the gitlab repo."
  exit 1
fi

configFile=$1

# This will create all the artifacts of a root CA and put them in the directory /tmp/certs/rootCA
rootDir='/tmp/certs/rootCA'
rm -rf $rootDir
mkdir -p $rootDir
cd $rootDir
mkdir certs crl newcerts private
touch index.txt
echo 1000 > serial

cd $rootDir

# create the root key - using RSA instead of AES256
openssl genrsa -aes256 -out ${rootDir}/private/ca.key.pem -passout pass:changeMe 4096
if [ $? -ne 0 ];then echo "ERROR creating private key"; exit 1; fi

# create the root certificate
openssl req -config $configFile -key ${rootDir}/private/ca.key.pem -new -x509 -days 3650 -sha256 -extensions v3_ca -passin pass:changeMe -out ${rootDir}/certs/ca.cert.pem -subj "/C=US/ST=Wisconsin/L=Madison/O=Singlewire Software Root CA/OU=Dev"
if [ $? -ne 0 ];then echo "ERROR creating root certificate"; exit 1; fi

# verify the root certificate
openssl x509 -noout -in ${rootDir}/certs/ca.cert.pem
if [ $? -ne 0 ];then echo "ERROR verifying certificate"; exit 1; fi

echo "*************************"
echo "Root Certificate verified"
echo "public certificate      = ${rootDir}/certs/ca.cert.pem"
echo "private key             = ${rootDir}/private/ca.key.pem"
