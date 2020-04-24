#!/bin/bash

# This script generates a bunch of different certificates and keys which
# which can be used for a variety of situations.

# https://www.digicert.com/kb/ssl-support/openssl-quick-reference-guide.htm - about creating and signing
# https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/ - root CA description
# https://www.feistyduck.com/library/openssl-cookbook/online/ch-openssl.html - really good overview of openssl

OPENSSL=/usr/bin/openssl
parentSubject="/C=US/ST=Wisconsin/L=Madison/O=Singlewire Software/OU=Dev"

# Some functions need a random password. This generates one
# and stores it in a file.
function generateRandomPasswordFile {
	#echo "generateRandomPasswordFile"
	local destPasswordFile=$1
	$OPENSSL rand -base64 48 > $destPasswordFile
}

# This actually generates both a private and public key. It stores both in the
# destination file. See extractPublicKeyFromPrivateKey below.
# This method of creating a key doesn't use a passphrase
# The resulting key is in PEM format which is a base64 translation of x509 ASN.1 keys
function generatePrivateRSAKey {
	#echo "generatePrivateRSAKey"
	local privateKeyDest=$1
	# generate a 2048 bit private RSA key
	$OPENSSL genrsa -out $privateKeyDest 2048
	if [ $? -ne 0 ]
	then
		echo "ERROR: unable to generate private key"
		exit 1
	fi
}

# prints the contents of a private key generated with generatePrivateRSAKey
function printPrivateKey {
	local privateKey=$1
	# -noout omits the output of the encoded version of the private key
	$OPENSSL rsa -text -in $privateKey -noout
	if [ $? -ne 0 ]
	then
		echo "ERROR: unable to print private key"
		exit 1
	fi

}

# extracts the public key from the private key generated with generatePrivateRSAKey
# This generally isn't needed.
function extractPublicKeyFromPrivateKey {
	#echo "extractPublicKeyFromPrivateKey"
	local privateKey=$1
	local publicKey=$2
	$OPENSSL rsa -in $privateKey -pubout -out $publicKey
	if [ $? -ne 0 ]
	then
		echo "ERROR: unable to extract public key to $publicKey"
		exit 1
	fi

}

# create a CSR given the private key, the destination CSR file and the CSR subject.
# the subject should include everything up to and including the CN=FQDN
function createCSR {
	#echo "createCSR"
	local privateKey=$1
	local subj=$2
	local csrFile=$3

	$OPENSSL req -new -key $privateKey -out $csrFile -subj "${subj}"
	if [ $? -ne 0 ]
	then
		echo "ERROR: unable to create CSR"
		exit 1
	fi
}

# Verifies the CSR you created is valid. Check the Subject: setting.
function verifyCSR {
	#echo "verifyCSR"
	local csrFile=$1
	$OPENSSL req -text -in $csrFile	 -noout -verify | grep "Subject:"
		if [ $? -ne 0 ]
	then
		echo "ERROR: unable to verify CSR"
		exit 1
	fi
}

# If you are going to self-sign the certificate You pass in the private key, the
# CSR and the result will be put in the certFile.
function signCertificate {
	#echo "signCertificate"
	local privateKey=$1
	local csrFile=$2
	local certFile=$3
	$OPENSSL x509 -req -days 36500 -in $csrFile -signkey $privateKey -out $certFile
	if [ $? -ne 0 ]
	then
		echo "ERROR: unable to sign certificate"
		exit 1
	fi
}

function printCertificate {
  #echo "printCertificate"
  local certFile=$1
  $OPENSSL x509 -text -in $certFile -noout
  if [ $? -ne 0 ]
	then
		echo "ERROR: unable to print certificate"
		exit 1
	fi
}

function modulusCheckKeys {
  #echo "modulusCheckKeys"
  local privateKey=$1
  local csrFile=$2
  local certFile=$3
  $OPENSSL rsa -modulus -in $privateKey -noout |openssl sha256
  $OPENSSL req -modulus -in $csrFile -noout |openssl sha256
  $OPENSSL x509 -modulus -in $certFile -noout |openssl sha256
}

# Pass in a private key and a subject and it will generate your own CA cert
function createRootCA {
  #echo "createRootCA"
  local privateKey=$1
  local subject=$2
  local rootCACert=$3

  $OPENSSL req -x509 -new -nodes -key $privateKey -sha256 -days 36500 -out $rootCACert -subj "${subject}"
  if [ $? -ne 0 ]
	then
		echo "ERROR: unable to create root CA"
		exit 1
	fi
}
# createEverythingMethod1
# 1 - creates a private key
# 2 - prints the private key
# 3 - prints the public key from the private key
# 4 - generates a CSR from the private key and subject
# 5 - verifies the CSR
# 6 - self-signs a certificate
# 7 - view your certificate

function createSelfSignedCertificateFromNothing {
  #echo "createSelfSignedCertificateFromNothing"
  local certDir=$1
  local host=$3
  local subject="$2/CN=$host"

  mkdir -p $certDir 2> /dev/null
  rm ${certDir}/* 2> /dev/null

  local privateKey=${certDir}/site.key
  # publicKey=${certDir}/my-public.key
  local csrFile=${certDir}/site.csr
  local certFile=${certDir}/site.crt

  generatePrivateRSAKey $privateKey
  # printPrivateKey $privateKey
  # extractPublicKeyFromPrivateKey $privateKey $publicKey
  createCSR $privateKey "${subject}" $csrFile
  verifyCSR $csrFile
  signCertificate $privateKey $csrFile $certFile
  # printCertificate $certFile
  modulusCheckKeys $privateKey $csrFile $certFile

  echo "==========================================================="
  echo "Site private key " $privateKey
  #echo "public key  " $publicKey
  echo "Site CSR         " $csrFile
  echo "Site cert        " $certFile
  echo "==========================================================="
}

function createConfigFileWithSAN {
  #echo "createConfigFileWithSAN"
  local destFile=$1
  local dns1=$2
  local dns2=$3
  local orgName=$4

  cat > $destFile <<EOF
[ req ]
default_bits        = 2048
distinguished_name  = subject
req_extensions      = req_ext
x509_extensions     = x509_ext
string_mask         = utf8only

[ subject ]
countryName                 = US
countryName_default         = US
stateOrProvinceName         = WI
stateOrProvinceName_default = WI
localityName                = Madison
localityName_default        = Madison
organizationName            = $orgName
organizationName_default    = $orgName
commonName                  = $dns1
commonName_default          = $dns1

[ x509_ext ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer
basicConstraints       = CA:FALSE
keyUsage               = digitalSignature, keyEncipherment
subjectAltName         = @alternate_names
nsComment              = "OpenSSL Generated Certificate"

[ req_ext ]
subjectKeyIdentifier = hash
basicConstraints     = CA:FALSE
keyUsage             = digitalSignature, keyEncipherment
nsComment            = "OpenSSL Generated Certificate"
subjectAltName = @alternate_names

[ alternate_names ]
DNS.1 = $dns1
DNS.2 = $dns2
EOF
}
function createSignedCertFromCA {
  #echo "createSignedCertFromCA"
  local caPrivateKey=$1
  local caCert=$2
  local csrFile=$3
  local siteCert=$4
  local confFile=$5
  confArg=''
  if [ ! -z "$confFile" ]
  then
    confArg="-extfile $confFile"
  fi

  $OPENSSL x509 -req -in $csrFile -CA $caCert -CAkey $caPrivateKey -CAcreateserial -out $siteCert -days 36500 -sha256 $confArg

  if [ $? -ne 0 ]
	then
		echo "ERROR: unable to create signed cert from CA"
		exit 1
	fi
}
function createCASignedCertificateFromNothing {
  #echo "createCASignedCertificateFromNothing"
  local certDir=$1
  local caSubject=$2
  local host=$4
  local siteSubject="$3/CN=$host"
  local ipList=$5
  mkdir -p $certDir 2>/dev/null
  rm ${certDir}/* 2> /dev/null

  local caPrivateKey=${certDir}/ca-root-private.key
  local caCert=${certDir}/ca-root.crt
  local sitePrivateKey=${certDir}/site.key
  local siteCSR=${certDir}/site.csr
  local siteCert=${certDir}/site.crt
  local configFile=${certDir}/site.config

  generatePrivateRSAKey $caPrivateKey
  createRootCA $caPrivateKey "${caSubject}" $caCert
  generatePrivateRSAKey $sitePrivateKey
  createCSR $sitePrivateKey "${siteSubject}" $siteCSR
  createConfigFileWithSAN $configFile $host "$ipList" "Singlewire Software LLC"
  createSignedCertFromCA $caPrivateKey $caCert $siteCSR $siteCert $configFile

  echo "==========================================================="
  echo "CA root private key  " $caPrivateKey
  echo "CA root cert         " $caCert
  echo "CA serial            " ${certDir}/ca-root.srl
  echo "Site private key     " $sitePrivateKey
  echo "Site CSR             " $siteCSR
  echo "Site cert            " $siteCert
  echo "Config file with SAN " $configFile
  echo "==========================================================="
}

function createCAandICASignedCertificateFromNothing {
  local certDir=$1
  local caSubject=$2
  local host=$3
  local siteSubject="$2/CN=$host"
  local host=$3
  local ipList=$4
  mkdir -p $certDir 2>/dev/null
  rm ${certDir}/* 2> /dev/null

  local caPrivateKey=${certDir}/ca-root-private.key
  local caCert=${certDir}/ca-root.crt

  # generate root CA
  generatePrivateRSAKey $caPrivateKey
  createRootCA $caPrivateKey "/C=US/ST=Wisconsin/L=Madison/O=Singlewire Software Fake Root CA/OU=Dev" $caCert

  local icaPrivateKey=${certDir}/ica-private.key
  local icaCert=${certDir}/ica.crt
  local icaCsr=${certDir}/ica.csr
  local icaConfig=${certDir}/ica.config
  # generate ICA from root CA
  generatePrivateRSAKey $icaPrivateKey
  createCSR $icaPrivateKey "/C=US/ST=Wisconsin/L=Madison/O=Singlewire Software Fake Intermediate CA/OU=Dev" $icaCsr
  createConfigFileWithSAN $icaConfig "" "" "Singlewire Software Fake Intermediate CA"
  createSignedCertFromCA $caPrivateKey $caCert $icaCsr $icaCert $icaConfig 

  local sitePrivateKey=${certDir}/site.key
  local siteCert=${certDir}/site.crt
  local siteCsr=${certDir}/site.csr
  local siteConfig=${certDir}/site.config
  # generate site cert from ICA
  generatePrivateRSAKey $sitePrivateKey

  createCSR $sitePrivateKey "${siteSubject}" $siteCsr
  createConfigFileWithSAN $siteConfig $host $ipList "Singlewire Software Actual Site"
  createSignedCertFromCA $icaPrivateKey $icaCert $siteCsr $siteCert $siteConfig 

  echo "==========================================================="
  echo "CA root private key  " $caPrivateKey
  echo "CA root cert         " $caCert
  echo "CA serial            " ${certDir}/ca-root.srl
  echo "ICA private key      " $icaPrivateKey
  echo "ICA CSR              " $icaCsr
  echo "ICA cert             " $icaCert
  echo "ICA Config file      " $icaConfig
  echo "Site private key     " $sitePrivateKey
  echo "Site CSR             " $siteCsr
  echo "Site cert            " $siteCert
  echo "Site Config file SAN " $siteConfig
  echo "==========================================================="
}
function createSelfSignedCertificateFromNothingWithSAN {
  local certDir=$1
  local host=$3
  local subject="$2/CN=$host"
  local ipList=$4
  mkdir -p $certDir 2>/dev/null
  rm ${certDir}/* 2> /dev/null

  local configFile=${certDir}/site.config
  local sitePrivateKey=${certDir}/site.key
  local siteCert=${certDir}/site.crt

  createConfigFileWithSAN $configFile $host "$ipList"
  $OPENSSL req -config $configFile -new -sha256 -newkey rsa:2048 -nodes -keyout $sitePrivateKey -x509 -days 36500 -out $siteCert -subj "${subject}"
  if [ $? -ne 0 ]
	then
		echo "ERROR: unable to create signed cert with SAN"
		exit 1
	fi
  echo "==========================================================="
	echo "Site private key     " $sitePrivateKey
	echo "Site cert            " $siteCert
	echo "Config file with SAN " $configFile
	echo "==========================================================="
}
if [ $# -lt 2 ]
then
  echo "ERROR: You must specify a host name and ip address for the certs"
  exit 1
fi

host=$1
ip=$2
subject="${parentSubject}/CN=${host}"
caSubject="${parentSubject}/CN=Singlewire Software LLC"

createSelfSignedCertificateFromNothing /tmp/certs-self-signed "$parentSubject" $host
createCASignedCertificateFromNothing "/tmp/ca-certs" "${caSubject}" "${parentSubject}" $host $ip
createSelfSignedCertificateFromNothingWithSAN "/tmp/san-certs" "${parentSubject}" $host $ip
createCAandICASignedCertificateFromNothing "/tmp/ica-certs" "${parentSubject}" $host $ip
