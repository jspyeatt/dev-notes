# openssl

## Create a Self-signed Certificate
```bash
openssl req -x509 -nodes -days 99999 -newkey rsa:2048 -keyout mysitename.key -out mysitename.crt
```
## Outbut a Certificate
```bash
openssl x509 -in mysitename.crt -text
```
