# My Security Notes

## keytool
`keytool` command works with keys, certificates and keystores.
* [tutorial] (http://tutorials.jenkov.com/java-cryptography/keytool.html)

Note, JKS is a proprietary format and PKCS12 is more the standard. So if possible use PKCS12.

One difference between the 2 is for JKS you can have a separate password for each keypair
in the keystore. For PKCS12 you only have the storepass.

### Generate a Public/Private Key Pair (PKCS12)
```
keytool -genkeypair -alias firstkeypair -keyalg RSA -keysize 2048 -dname "CN=John Pyeatt, OU=Development, O=My Company, L=Madison, ST=Wisconsin, C=US" -validity 9999 -storetype PKCS12 -keystore mykeystore.pkcs12 -storepass abcdef
```
Add another keypair to the same file.
```
keytool -genkeypair -alias secondkeypair -keyalg RSA -keysize 2048 -dname "CN=John Pyeatt, OU=Development, O=My Company, L=Madison, ST=Wisconsin, C=US" -validity 9999 -storetype PKCS12 -keystore mykeystore.pkcs12 -storepass abcdef
```
### Generate a Public/Private Key Pair (JKS)

```
keytool -genkeypair -alias firstkeypair -keyalg RSA -keysize 2048 -dname "CN=John Pyeatt, OU=Development, O=My Company, L=Madison, ST=Wisconsin, C=US" -keypass 123456 -validity 9999 -storetype JKS -keystore mykeystore.jks -storepass abcdef
```
* -alias an alias name for the keystore entry. If you have multiple keys in the keystore they would
all have different aliases.
* -keyalg the name of the algorithm used to generate the key. RSA being a typical one.
* -keysize the size in bits of the key to generate. Needs to be multiples of 8. Size is limited by keyalg value.
* -dname distinguished name from X.500 standard. The name will be associated with the alias of the keypair. The 
dname is also used and the `issuer` and `subject` of a self-signed cert.
* -keypass the password of the key entry within the keystore
* -validity number of days the certificate associated with the keypair is valid.
* -storetype the file format of the keystore (JKS|PKCS11)
* -keystore the name of the resulting keystore file on the file system.
* -storepass the password for the entire keystore.

#### Importing to PKCS12
```
keytool -importkeystore -srckeystore mykeystore.jks -destkeystore mykeystore.pkcs12 -deststoretype pkcs12
```
Then answer prompts. Here are the answers based on the example above.
1. Enter destination keystore password: 123456
1. Enter source keystore password: abcdef
1. Enter key password for <firstkeypair>: 123456

Note for pkcs12 the new keystore password and key password must match. That's why they are both 123456

### Listing Keystore Entries
```
keytool -list -storetype JKS -keystore mykeystore.jks --storepass abcdef
```
```
keytool -list -storetype PKCS12 -keystore mykeystore.pkcs12 --storepass 123456
```
Interrogate with RFC-1421 format
```
keytool -list -storetype PKCS12 -keystore mykeystore.pkcs12 --storepass 123456 --rfc
```

### Exporting a Key Pair Cert
```
keytool -exportcert -alias firstkeypair -file destination.crt -keystore mykeystore.pkcs12 -storepass abcdef -storetype PKCS12
```
### Importing a Cert
```
keytool -importcert -alias mynewcert -file source.crt -keystore mykeystore.pkcs12 -storepass abcdef -storetype PKCS12
```
### Generate a Certificate Request
Generating a certificate request for firstkeypair.
```
keytool -certreq -alias firstkeypair -storetype PKCS12 -keystore mykeystore.pkcs12 -storepass abcdef -file destcertreq.certreq
```
### Generate a Self-Signed Cert
```
keytool -genkey -keyalg RSA -alias myselfcert -keystore selfsigned.pkcs12 -validity 9999 -keysize 2048 -storetype PKCS12 -dname "CN=John Pyeatt, OU=Development, O=My Company, L=Madison, ST=Wisconsin, C=US" -storepass ZZZZZZ
```
Then run the list command to verify.
```
keytool -list -v -keystore selfsigned.pkcs12 -storetype PKCS12 -storepass ZZZZZZ
```
## OpenSSL

1. Generate a Key Pair into MyKeyPair.key
```bash
openssl genrsa -aes128 -out MyKeyPair.key
```
2. Generate a Certificate for the Key into MyCert.crt
```bash
openssl req -new -x509 -newkey rsa:2048 -sha256 -key MyKeyPair.key -out MyCert.crt
```

### Loading Keys and Certs via PKCS12
If you have a key and cert in separate files and need to combine them into a PKCS12 format to load into a new keystore.

```bash
openssl pkcs12 -inkey SOURCE.key -in SOURCE.crt -export -out my.pkcs12
```
If you have a chain of certs because your Certificate Authority is an intermediary you can create a pkcs12 file like this:
```bash
cat example.crt intermediate-1.crt intermediate-2.crt rootCA.crt > cert-chain.txt
openssl pkcs12 -export -inkey SOURCE.key -in cert-chain.txt -out my.pkcs12
```
### Creating Sample Keystore
```bash
openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 3650 -out certificate.pem
openssl x509 -text -noout -in certificate.pem
openssl pkcs12 -inkey key.pem -in certificate.pem -export -out idp-browser.p12
```
### Converting Certs from Trusted Providers to .jks file
This is usually done for our mobile api. For our example whenever you are prompted for a password use `asdf1234!!`

1. create `/tmp/qadevJune2019unprotected.key` and put the contents in the file.
1. create `/tmp/star_qadev_singlewire_com.crt` and put the contents in the file.
1. `openssl pkcs12 -export -in /tmp/star_qadev_singlewire_com.crt -inkey /tmp/qadevJune2019unprotected.key -name "restapi" -out restapi.p12`    This will create a .p12 file format from your certificate and your key.
1. `keytool -importkeystore -destkeystore keystore.jks -srckeystore restapi.p12 -srcstoretype PKCS12`  This will convert 
1. `keytool -list -v -keystore keystore.jks` verify output by checking for new expiration date.
