# Openssl cert notes
The scripts created below are based on this [really good tutorial](https://jamielinux.com/docs/openssl-certificate-authority/introduction.html).

This is also useful for interpreting [status code values](https://www.spiderbird.com/2015/08/02/openssl-s_client-to-verify-you-installed-your-certificate-properly-and-list-of-return-codes/).

The certificates will be created under the directory ${HOME}/my-certs.

There is an audit log that is created as part of this process. The file my-certs/intermediate/index.txt will keep a list of all the certificates
created with the intermediate CA. The file my-certs/intermediate/serial contains a counter for the next certificate created.

The normal flow of this will be:
1. ./create-root-ca.sh - you run this one time.
1. ./create-intermediate-ca.sh - you run this one time.
1. ./create-server-cert.sh - you can run this as many times as you want, you just need to change the hostname each time. It
will not let you create a certificate with the same name twice.

## create-root-ca.sh
Creates a root certificate. It uses the extensions defined in openss-root.cnf. The resulting
certificates can be found in ${HOME}/my-certs/rootCA.

## create-intermediate-ca.sh
Creates an intermediate certificate using the root certificate created with create-root-ca.sh.

The resulting artifacts end up in ${HOME}/my-certs/intermediate.

Note, when you create an intermediate cert from the root certificate a copy of the intermediate
certificate ends up in the rootCA/newcerts directory. So you cannot create another intermeidate
certificate with the same common name.

## create-server-cert.sh
You can use this to create as many certificates as you like. But, you can't create a certificate
for the same host twice because data about the previously created certificates is stored in the 
directory structure.
