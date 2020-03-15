#!/bin/bash

# This script generates a bunch of different certificates and keys which
# which can be used for a variety of situations.

# https://www.digicert.com/kb/ssl-support/openssl-quick-reference-guide.htm - about creating and signing
# https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/ - root CA description
OPENSSL=/usr/bin/openssl
parentSubject="/C=US/ST=Wisconsin/L=Madison/O=Singlewire Software/OU=Dev"

# Some functions need a random password. This generates one
# and stores it in a file.
function generateRandomPasswordFile {
	echo "generateRandomPasswordFile"
	destPasswordFile=$1
	$OPENSSL rand -base64 48 > $destPasswordFile
}

# This actually generates both a private and public key. It stores both in the
# destination file. See extractPublicKeyFromPrivateKey below.
# This method of creating a key doesn't use a passphrase
# The resulting key is in PEM format which is a base64 translation of x509 ASN.1 keys
function generatePrivateRSAKey {
	echo "generatePrivateRSAKey"
	privateKeyDest=$1
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
	echo "printPrivateKey"
	privateKey=$1
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
	echo "extractPublicKeyFromPrivateKey"
	privateKey=$1
	publicKey=$2
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
	echo "createCSR"
	privateKey=$1
	subj=$2
	csrFile=$3

	$OPENSSL req -new -key $privateKey -out $csrFile -subj "${subj}"
	if [ $? -ne 0 ]
	then
		echo "ERROR: unable to create CSR"
		exit 1
	fi
}

# Verifies the CSR you created is valid. Check the Subject: setting.
function verifyCSR {
	echo "verifyCSR"
	csrFile=$1
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
	echo "signCertificate"
	privateKey=$1
	csrFile=$2
	certFile=$3
	$OPENSSL x509 -req -days 36500 -in $csrFile -signkey $privateKey -out $certFile
	if [ $? -ne 0 ]
	then
		echo "ERROR: unable to sign certificate"
		exit 1
	fi
}

function printCertificate {
  echo "printCertificate"
  certFile=$1
  $OPENSSL x509 -text -in $certFile -noout
  if [ $? -ne 0 ]
	then
		echo "ERROR: unable to print certificate"
		exit 1
	fi
}

function modulusCheckKeys {
  echo "modulusCheckKeys"
  privateKey=$1
  csrFile=$2
  certFile=$3
  $OPENSSL rsa -modulus -in $privateKey -noout |openssl sha256
  $OPENSSL req -modulus -in $csrFile -noout |openssl sha256
  $OPENSSL x509 -modulus -in $certFile -noout |openssl sha256
}

# Pass in a private key and a subject and it will generate your own CA cert
function createRootCA {
  echo "createRootCA"
  privateKey=$1
  subject=$2
  rootCACert=$3

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
  echo "createSelfSignedCertificateFromNothing"
  certDir=$1
  subject=$2
  mkdir -p $certDir 2> /dev/null
  rm ${certDir}/* 2> /dev/null

  privateKey=${certDir}/my-private.key
  publicKey=${certDir}/my-public.key
  csrFile=${certDir}/my.csr
  certFile=${certDir}/my.crt
  generatePrivateRSAKey $privateKey
  # printPrivateKey $privateKey
  extractPublicKeyFromPrivateKey $privateKey $publicKey
  createCSR $privateKey "${subject}" $csrFile
  verifyCSR $csrFile
  signCertificate $privateKey $csrFile $certFile
  # printCertificate $certFile
  modulusCheckKeys $privateKey $csrFile $certFile

  echo "private key " $privateKey
  echo "public key  " $publicKey
  echo "CSR file    " $csrFile
  echo "Cert file   " $certFile
}

function createConfigFileWithSAN {
  echo "createConfigFileWithSAN"
  destFile=$1
  dns1=$2
  dns2=$3
  echo "authorityKeyIdentifier=keyid,issuer" > $destFile
  echo "basicConstraints=CA:FALSE" >> $destFile
  echo "keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment" >> $destFile
  echo "subjectAltName = @alt_names" >> $destFile
  echo "" >> $destFile
  echo "[alt_names]" >> $destFile
  echo "DNS.1 = ${dns1}" >> $destFile
  echo "DNS.2 = ${dns2}" >> $destFile
}
function createSignedCertFromCA {
  echo "createSignedCertFromCA"
  caPrivateKey=$1
  caCert=$2
  csrFile=$3
  confFile=$4
  siteCert=$5
  $OPENSSL x509 -req -in $csrFile -CA $caCert -CAkey $caPrivateKey -CAcreateserial -out $siteCert -days 36500 -sha256 -extfile $confFile

  if [ $? -ne 0 ]
	then
		echo "ERROR: unable to create signed cert from CA"
		exit 1
	fi
}
function createCASignedCertificateFromNothing {
  echo "createCASignedCertificateFromNothing"
  certDir=$1
  caSubject=$2
  siteSubject=$3
  host=$4
  ipList=$5
  mkdir -p $certDir 2>/dev/null
  rm ${certDir}/* 2> /dev/null

  caPrivateKey=${certDir}/ca-root-private.key
  caCert=${certDir}/ca-root.crt
  sitePrivateKey=${certDir}/site.key
  siteCSR=${certDir}/site.csr
  siteCert=${certDir}/site.crt
  configFile=${certDir}/site.config

  generatePrivateRSAKey $caPrivateKey
  createRootCA $caPrivateKey "${caSubject}" $caCert
  generatePrivateRSAKey $sitePrivateKey
  createCSR $sitePrivateKey "${siteSubject}" $siteCSR
  createConfigFileWithSAN $configFile $host "$ipList"
  createSignedCertFromCA $caPrivateKey $caCert $siteCSR $configFile $siteCert

  echo "CA root private key  " $caPrivateKey
  echo "CA root cert         " $caCert
  echo "Site private key     " $sitePrivateKey
  echo "Site CSR             " $siteCSR
  echo "Site cert            " $siteCert
  echo "Config file with SAN " $configFile
}
host="jspyeatt.qadev.singlewire.com"
subject="${parentSubject}/CN=${host}"
caSubject="${parentSubject}/CN=Singlewire Software LLC"

# createSelfSignedCertificateFromNothing /tmp/certs-self-signed "$subject"
createCASignedCertificateFromNothing "/tmp/ca-certs" "${caSubject}" "${subject}" $host "172.20.127.120 172.20.146.120"
