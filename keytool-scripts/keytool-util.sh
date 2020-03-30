#!/bin/bash

# this script gneerates a public/private keypair and puts
# the result in keystore.jks.
# it then converts the keystore from jks to pkcs12 format
# and puts the result in keystore.pkcs12
#

if [ $# -lt 2 ]
then
  echo "ERROR: you must specify an ip address and keystore password"
  exit 1
fi
certDir=/tmp/keytool-certs
mkdir -p $certDir
jksKeystore="${certDir}/keystore.jks"
pkcs12Keystore="${certDir}/keystore.pkcs12"
host=$1
pw=$2


subject="CN=$host,OU=Development,O=Singlewire Pyeatt,L=Madison,ST=Wisconsin,C=US"

echo "==========================="
echo "generate a self-signed cert in jks"
keytool \
  -genkeypair \
  -alias tomcat \
  -keyalg RSA \
  -dname "$subject" \
  -keypass $pw \
  -validity 9999 \
  -storetype JKS \
  -keystore ${jksKeystore} \
  -storepass $pw
if [ $? -ne 0 ]
then
  echo "Error: unable to create keypair"
  exit 1
fi

echo "================================="
echo "convert keystore to pkcs12 format"
keytool \
  -importkeystore \
  -srckeystore ${jksKeystore} \
  -destkeystore ${pkcs12Keystore} \
  -deststoretype pkcs12 \
  -srcstorepass $pw \
  -deststorepass $pw
if [ $? -ne 0 ]
then
  echo "Error: unable to convert keypair to pkcs12"
  exit 1
fi

echo "================================="
echo "list the contents of the keystore"

keytool \
  -list \
  -alias tomcat \
  -storetype PKCS12 \
  -keystore ${pkcs12Keystore} \
  -storepass $pw \
  -v

if [ $? -ne 0 ]
then
  echo "Error: unable to list the keys"
  exit 1
fi

echo " -------------------------------------------------  "
echo "DONE: All your certs are in $certDir"
echo " -------------------------------------------------  "
