# Apache Notes

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
