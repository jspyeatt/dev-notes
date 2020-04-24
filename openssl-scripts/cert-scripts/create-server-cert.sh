#!/bin/bash

if [ $# -lt 2 ]
then
  echo "ERROR: You must specify the directory of your openssl-root.cnf file. It should be in the root of the gitlab repo."
  exit 1
fi

configDir=$1
host=$2
rootDir='/tmp/certs/intermediate'
keyFile=${rootDir}/private/${host}.key.pem
csrFile=${rootDir}/csr/${host}.csr.pem
hostCertFile=${rootDir}/certs/${host}.cert.pem

# create private key
openssl genrsa -aes256 -out ${keyFile} 2048
if [ $? -ne 0 ];then echo "ERROR creating private key"; exit 1; fi

# create csr
openssl req -config ${configDir}/openssl-intermediate.cnf -new -sha256 -key ${keyFile} -out ${csrFile} -passin pass:changeMe -subj "/C=US/ST=Wisconsin/L=Madison/O=Pyeatt/OU=Dev/CN=${host}"
if [ $? -ne 0 ];then echo "ERROR creating server signing request"; exit 1; fi

# create server certificate
openssl ca -batch -config ${configDir}/openssl-intermediate.cnf -extensions server_cert -days 3650 -notext -md sha256 -in ${csrFile} -out ${hostCertFile} -passin pass:changeMe
if [ $? -ne 0 ];then echo "ERROR creating server certificate"; exit 1; fi

# verify the intermediate certificate
openssl x509 -text -in ${hostCertFile}
if [ $? -ne 0 ];then echo "ERROR verifying certificate"; exit 1; fi

echo ""
echo "***********************************************************************"
echo "Server Certificate verified"
echo "host                    = $host"
echo "public certificate      = ${hostCertFile}"
echo "private key             = ${keyFile}"
echo "*
