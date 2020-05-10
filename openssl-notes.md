# openssl
I've got more stuff [here](https://github.com/jspyeatt/dev-notes/blob/master/security-notes.md) too.

## Create a Self-signed Certificate
```bash
openssl req -x509 -nodes -days 99999 -newkey rsa:2048 -keyout mysitename.key -out mysitename.crt
```
## Output a Certificate
```bash
openssl x509 -in mysitename.crt -text
```
## Create a Self-signed Certificate without Prompting
### Generate passphrase
```bash
openssl rand -base64 48 > passphrase.txt
```
### Generate a Private Key
```bash
openssl genrsa -aes128 -passout file:passphrase.txt -out server.key 2048
```

### Generate a CSR (Certificate Signing Request)
```bash
openssl req -new -passin file:passphrase.txt -key server.key -out server.csr \
    -subj "/C=OU/S=WI/L=Madison/O=Singlewire Software/OU=Dev Team/CN=jspyeatt.qadev.singlewire.com"
```

### Remove Passphrase from Key
```bash
cp server.key server.key.org
openssl rsa -in server.key.org -passin file:passphrase.txt -out server.key
```

### Generating a Self-Signed Certificate for 100 years
```bash
openssl x509 -req -days 36500 -in server.csr -signkey server.key -out server.crt
```
### Verifying a Certificate
If you've generated a root CA certificate and used it to sign a server (child) certificate you can 
verify the trust chain.
```bash
openssl verify -CAfile root-ca.pem child-cert.pem
```

## Create your own Root CA and Server certificate
When you run through these steps you will have the following:

1. ca.key - private key for the root CA
1. ca.crt - public certificate for the root CA
1. mysite.key - private key for the server
1. mysite.csr - certificate signing request for the server
1. mysite.crt - public certificate for the server.

### Generate Root CA private key
```bash
openssl genrsa -out ca.key 4096
```
### Sign the Root CA certificate
```bash
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt -subj "/C=US/ST=WI/O=Dummy Org/CN=Fake Root CA"
```
### Create the Server private key
```bash
openssl genrsa -out mysite.key 4096
```
### Create the CSR for the Server
```bash
openssl req -new -sha256 -key mysite.key  -subj "/C=US/ST=WI/O=Dummy Org/CN=jspyeatt.singlewire.com" -out mysite.csr
```
### Verify the CSR's Content
```bash
openssl req -in mysite.csr -noout -text
```
### Sign the CSR to Create the Server Certificate
```bash
openssl x509 -req -in mysite.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out mysite.crt -days 3650 -sha256
```
### Verify the Certificate
```bash
openssl verify -CAfile ca.crt mysite.crt
mysite.crt: OK
```
