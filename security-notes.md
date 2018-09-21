# My Security Notes

## keytool
`keytool` command works with keys, certificates and keystores.
* [tutorial] (http://tutorials.jenkov.com/java-cryptography/keytool.html)

### Generate a Public/Private Key Pair
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
