#!/bin/bash

if [ $# -lt 1 ]
then
  echo "ERROR: You must specify the host name."
  exit 1
fi
host=$1

scriptDir=$PWD
baseCertDir=$HOME/my-certs
configDir=${baseCertDir}/conf

if [ ! -e "${configDir}/openssl-intermediate.cnf" ]
then
   echo "ERROR: It appears you haven't created your intermediate ca certificate yet. Did you run create-intermediate-ca.sh?"
   exit 1
fi

certRootDir=${baseCertDir}/rootCA
certIntermediateDir=${baseCertDir}/intermediate

keyFile=${certIntermediateDir}/private/${host}.key.pem
csrFile=${certIntermediateDir}/csr/${host}.csr.pem
hostCertFile=${certIntermediateDir}/certs/${host}.cert.pem

# create private key
openssl genrsa -aes256 -passout pass:changeMe -out ${keyFile} 2048
if [ $? -ne 0 ];then echo "ERROR creating private key"; exit 1; fi

# create csr
openssl req -config ${configDir}/openssl-intermediate.cnf -new -sha256 -key ${keyFile} -out ${csrFile} -passin pass:changeMe -subj "/C=US/ST=Wisconsin/L=Madison/O=Fake Certs/OU=Dev/CN=${host}"
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
echo "***********************************************************************"
