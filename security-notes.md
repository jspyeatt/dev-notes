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
keytool -list -storetype JKS --keystore mykeystore.jks --storepass abcdef
```
```
keytool -list -storetype PKCS12 --keystore mykeystore.pkcs12 --storepass 123456
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
