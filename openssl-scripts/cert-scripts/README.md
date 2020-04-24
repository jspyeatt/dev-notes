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

### Installed in a server. 
Let's say you've installed the certificate and private key for the hostname into a server like
apache. Once you've done that you can verify the certificate chain by doing the following commands.


```bash
mkdir /tmp/certs
cd /tmp/certs
cp $HOME/my-certs/rootCA/certs/ca.pem .
cp $HOME/my-certs/intermediate/certs/intermediate.cert.pem .
openssl rehash /tmp/certs
openssl s_client -CApath /tmp/certs -connect jspyeatt.singlewire.com:22443 -showcerts
```
This should return 0 and should also have the line `Verify return code: 0 (ok)`.

### The password encrypted private key.
**IMPORTANT**: This script creates a private key which is password protected. 

Sometimes Apache won't start if the private key is password protected. You can fix this be either 
removing the password from the private key or add the `SSLPassPhraseDialog` to your apache's configuration
file where appropriate. Below are the steps to remove the password.

To confirm this you can run the command
```bash
head -3 PRIVATE_KEY_FILE
```
If it has something like 
```
Proc-TYpe: 4,ENCRYPTED
```
It's an encrypted keyfile.

You can convert an encrypted password keyfile to one that is not encrypted you can run the following:
```bash
mv PRIVATE_KEY_FILE old.key  # move the original key file to a temporary location
openssl rsa -in old.key -out PRIVATE_KEY_FILE # convert from password protected to not password protected.
```

