# Apache Notes

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
