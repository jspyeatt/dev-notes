[[_TOC_]]
# Apache Notes

## Adding Certificates to Apache
There are two things you normally want to do with regard to certificates.

### Create and Insert a Self-Signed Certificate

Set your CN= value appropriately.
```bash
openssl req \
       -x509 \
       -newkey rsa:2048 \
       -keyout /etc/apache2/certs/cert-private.key \
       -out /etc/apache2/certs/cert.crt \
       -days 36500 \
       -subj "/C=US/ST=Wisconsin/L=Madison/O=Singlewire/OU=Self Signed Cert/CN=jspyeatt.qadev.singlewire.com" \
       -nodes
```
Then in your 000-default.conf file you are going to do something like this
```
<VirtualHost *:22443>
   DocumentRoot /var/www/html
   ErrorLog ${APACHE_LOG_DIR}/error_22443.log
   CustomLog ${APACHE_LOG_DIR}/access_22443.log combined

   SSLEngine on
   SSLCertificateFile /etc/apache2/certs/cert.crt
   SSLCertificateKeyFile /etc/apache2/certs/cert-private.key
   
   #SSLCertificateChainFile /etc/ssl/certs/ca-certificates.crt
</VirtualHost>
```
### Adding a Cert Signed with your own CA
One of the other things you might have is your own certicate which you've signed with your own Certificate Authority (CA).
This CA is generally distributed within an organization and installed on people's laptops or browsers truststore so
you can hit internal sites without being prompted for allowing an untrusted site.

This can take several steps:
**Generate a Root CA**
If you don't already have a root CA
```bash
openssl req -new -x509 -keyout my-root-ca.key -out my-root-ca.crt -days 36500 -nodes -subj "/C=US/ST=Wisconsin/L=Madison/O=Singlewire/OU=Self Signed Cert With Root CA"
```
Once you've generated your Root CA you can add it to your system's certificates if you like.
```bash
cp my-root-ca.crt /usr/local/share/ca-certificates/  # note, your root CA must have a .crt extension
sudo update-ca-certificates
```
If you subsequently want to remove your root CA
```bash
rm /usr/local/share/ca-certificates/my-root-ca.crt
rm /etc/ssl/certs/my-root-ca.crt
sudo update-ca-certificates
```

**Generate a Private Key for your Certificate**
```bash
openssl genrsa -out my-cert-private.key 2048
```
**Create a Certificate Signing Request (CSR)**
```bash
openssl req -new -key my-cert-private.key -out my-cert.csr -days 3650 -subj "/C=US/ST=Wisconsin/L=Madison/O=Singlewire/OU=Self Signed Cert With Root CA/CN=jspyeatt.qadev.singlewire.com"
```
**Sign your Certificate with your Root CA"
```bash
openssl x509 -req -in my-cert.csr -CA my-root-ca.crt -CAkey my-root-ca.key -days 36500 -CAcreateserial -out my-cert.crt
```
**Print Resulting Certificate**
```bash
openssl x509 -text -in my-cert.crt
```

## Building Apache
Building apache httpd server is a pain because you need to include three other packages as well.
1. apr
1. apr-util
1. pcre
So you have to build those first. Once you have that done you can configure and build httpd.

```
./configure --prefix=/home/john/apache/httpd --with-apr=/home/john/apache/apr --with-apr-util=/home/john/apache/apr-util --with-pcre=/home/john/apache/pcre --enable-load-all-modules --enable-ssl
```

## Building a self-signed cert for Apache.
```
openssl req -x509 -newkey rsa:2048 -nodes -keyout pyeatt.key -out pyeatt.crt
```
Make certain when answering the questions you give it an appropriate FQDN. THen install the two files generated in the /conf
directory and make certain the file names match the directives `SSLCertificateFile` and `SSLCertificateKeyFile` in /conf/extra/httpd-ssl.conf.

## Configuring Apache to be a reverse proxy

1. Add the this entry to conf/httpd.conf `Include conf/extra/reverse-proxy.conf`
1. Create a file under conf/extras/reverse-proxy.conf
```
SSLProxyEngine on
SSLProxyVerify none
SSLProxyCheckPeerCN off
SSLProxyCheckPeerName off
SSLProxyCheckPeerExpire off
ProxyPass "/firedoor-app/" "http://127.0.0.1:22080/firedoor-app/"
ProxyPass "/InformaCast/RESTServices/V1/" "https://jspyeatt.qadev.singlewire.com:8444/InformaCast/RESTServices/V1/"
```
The SSLProxy* directives allow the proxy to send to secure backend servers with self-signed certs.
