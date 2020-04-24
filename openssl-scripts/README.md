# Openssl cert notes
The scripts created below are based on this [really good tutorial](https://jamielinux.com/docs/openssl-certificate-authority/introduction.html).

This is also useful for interpreting [status code values](https://www.spiderbird.com/2015/08/02/openssl-s_client-to-verify-you-installed-your-certificate-properly-and-list-of-return-codes/).
## create-root-ca.sh
Creates a root certificate. It uses the extensions defined in openss-root.cnf. The resulting
certificates can be found in /tmp/certs/rootCA.

## create-intermediate
Creates an intermediate certificate using the root certificate created with create-root-ca.sh

Note, when you create an intermediate cert from the root certificate a copy of the intermediate
certificate ends up in the rootCA/newcerts directory. So you cannot create another intermeidate
certificate with the same common name.

## create-server-cert.sh
You can use this to create as many certificates as you like. But, you can't create a certificate
for the same host twice because data about the previously created certificates is stored in the 
directory structure.
