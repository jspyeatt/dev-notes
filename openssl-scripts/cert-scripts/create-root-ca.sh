#!/bin/bash

# this script is based entirely on https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html

# also useful https://www.spiderbird.com/2015/08/02/openssl-s_client-to-verify-you-installed-your-certificate-properly-and-list-of-return-codes/

scriptDir=$PWD
baseCertDir=$HOME/my-certs
# This will create all the artifacts of a root CA and put them in the directory /tmp/certs/rootCA
certRootDir=${baseCertDir}/rootCA
configDir=${baseCertDir}/conf
keyFile=${certRootDir}/private/ca.key.pem
certFile=${certRootDir}/certs/ca.cert.pem
if [ -e $certFile ]
then
   echo "Error: $certFile already exists. If you really want to replace it you must remove it first"
   exit 1
fi
rm -rf $certRootDir
mkdir -p $certRootDir $configDir
cd $certRootDir
mkdir certs crl newcerts private
touch ${certRootDir}/index.txt
touch ${certRootDir}/index.txt.attr
echo 1000 > serial

sed -e "s!BASE_CERT_DIR!${baseCertDir}!" $scriptDir/openssl-root.cnf.template > ${configDir}/openssl-root.cnf
cd $certRootDir


# create the root key - using RSA instead of AES256
openssl genrsa -aes256 -out ${keyFile} -passout pass:changeMe 4096
if [ $? -ne 0 ];then echo "ERROR creating private key"; exit 1; fi

# create the root certificate
openssl req -config ${configDir}/openssl-root.cnf -key ${keyFile} -new -x509 -days 3650 -sha256 -extensions v3_ca -passin pass:changeMe -out ${certFile} -subj "/C=US/ST=Wisconsin/L=Madison/O=Fake Certs/OU=Dev/CN=Root CA"
if [ $? -ne 0 ];then echo "ERROR creating root certificate"; exit 1; fi

# verify the root certificate
openssl x509 -text -in ${certFile}
if [ $? -ne 0 ];then echo "ERROR verifying certificate"; exit 1; fi

echo ""
echo "***********************************************************************"
echo "Root Certificate verified"
echo "public certificate      = ${certFile}"
echo "private key             = ${keyFile}"
echo "***********************************************************************"
