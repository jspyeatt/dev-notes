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
