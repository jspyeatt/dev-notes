#!/bin/bash


scriptDir=$PWD
baseCertDir=$HOME/my-certs
configDir=${baseCertDir}/conf

certRootDir=${baseCertDir}/rootCA
certIntermediateDir=${baseCertDir}/intermediate
keyFile=${certIntermediateDir}/private/intermediate.key.pem
certFile=${certIntermediateDir}/certs/intermediate.cert.pem
csrFile=${certIntermediateDir}/csr/intermediate.csr.pem
if [ -e $certFile ]
then
   echo "Error: $certFile already exists. If you really want to replace it you must remove it first"
   exit 1
fi

rm -rf $certIntermediateDir
mkdir -p $certIntermediateDir
cd $certIntermediateDir
mkdir certs crl newcerts private csr
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber

sed -e "s!BASE_CERT_DIR!${certIntermediateDir}!" $scriptDir/openssl-intermediate.cnf.template > ${configDir}/openssl-intermediate.cnf

cd $certIntermediateDir

# create the private key - using RSA instead of AES256
openssl genrsa -aes256 -out ${keyFile} -passout pass:changeMe 4096
if [ $? -ne 0 ];then echo "ERROR creating private key"; exit 1; fi

# create csr
openssl req -config ${configDir}/openssl-intermediate.cnf -new -sha256 -key ${keyFile} -out ${csrFile} -passin pass:changeMe -subj "/C=US/ST=Wisconsin/L=Madison/O=Fake Certs/OU=Dev/CN=Intermediate CA"
if [ $? -ne 0 ];then echo "ERROR creating intermediate signing request"; exit 1; fi

# create intermediate certificate
openssl ca -batch -config ${configDir}/openssl-root.cnf -extensions v3_intermediate_ca -days 3650 -notext -md sha256 -in ${csrFile} -out ${certFile} -passin pass:changeMe
if [ $? -ne 0 ];then echo "ERROR creating intermediate certificate"; exit 1; fi

# verify the intermediate certificate
openssl x509 -text -in ${certFile}
if [ $? -ne 0 ];then echo "ERROR verifying certificate"; exit 1; fi

echo ""
echo "***********************************************************************"
echo "Intermediate Certificate verified"
echo "public certificate      = ${certFile}"
echo "private key             = ${keyFile}"
echo "***********************************************************************"

