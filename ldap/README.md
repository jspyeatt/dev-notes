# LDAP

A lot of this is based on https://www.linuxbabe.com/ubuntu/install-configure-openldap-server-ubuntu-16-04

## Installation

```bash
sudo apt-get install slapd ldap-utils
# if you want to enable it at startup
sudo systemctl enable slapd
sudo dpkg-reconfigure slapd   # follow the questions in the page provided at the top of this readme.
```

The configuration files for ldap are in `/etc/ldap/ldap.conf`. Make the modifications it states about BASE and URI.

Verify configuration with
```bash
ldapsearch -x
```
You should now be able to connect using the `admin` user for binding.

## Configuring for StartTLS Connection - Self Signed
Configuring openldap for secure connections is astonishingly hard if you have a trust chain. If you have a 
self-signed certificate, it isn't quite so bad.

Create the self-signed cert. specify the FQDN name of the server for the common name when asked

```bash
cd /etc/ldap/sasl2
sudo openssl req -x509 -nodes -days 99999 -newkey rsa:2048 -keyout mysitename.key -out mysitename.crt
sudo chown openldap /etc/ldap/sasl2/mysitename.key /etc/ldap/sasl2/mysitename.crt
sudo chmod 640 /etc/ldap/sasl2/mysitename.key
```
Create the ldif file we will use to change the configuration of openldap.
```
dn: cn=config
changetype: modify
add: olcTLSCACertificateFile
olcTLSCACertificateFile: /etc/ldap/sasl2/ca-certificates.crt
-
replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/ldap/sasl2/mysitename.crt
-
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/ldap/sasl2/mysitename.key

```
Now, with openldap running run the new configuration.

```bash
sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f ldap_ssl_self.ldif
```

Now modify /etc/ldap/ldap.conf to look something like this.
```
BASE dc=singlewire,dc=com
URI ldap://jspyeatt-ldap.singlwire.com
TLS_CERT /etc/ssl/certs/ca-certificates.crt
TLS_REQCERT allow
ssl start_tls
ssl on
```

Edit /etc/default/sldapd and make certain you have the line
```
SLAPD_SERVICES="ldap:/// ldapi:/// ldaps:///"
```
Restart slapd
```bash
sudo /etc/init.d/slapd restart
```

You should now be able to use port 389 for StartTLS and 636 for ldaps.

## Configuring for Secure Connections
https://computingforgeeks.com/secure-ldap-server-with-ssl-tls-on-ubuntu/
As expected this is really confusing.

Here's what I did.

Put the following scripts into /etc/ldap/my-certs

1. ca.cert.pem
1. ca.key.pem
1. intermediate.cert.pem
1. intermediate.key.pem
1. jspyeatt-ldap.singlewire.com.cert.pem
1. jspyeatt-ldap.singlewire.com.key.pem

I concatenated `cat intermediate.cert.pem ca.cert.pem > merge-ca-public-certs.pem`

Then created addcerts.ldif
```
dn: cn=config
changetype: modify
add: olcTLSCACertificateFile
olcTLSCACertificateFile: /etc/ldap/my-certs/merged-ca-public-certs.pem

add: olcTLSCertificateFile
olcTLSCertificateFile: /etc/ldap/my-certs/jspyeatt-ldap.singlewire.com.cert.pem

add: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/ldap/my-certs/jspyeatt-ldap.singlewire.com.key.pem
```

and ran
```bash
sudo ldapmodify -H ldapi:// -Y EXTERNAL -f /etc/ldap/my-certs/addcerts.ldif
```
Edited /etc/default/slapd to read
```
SLAPD_SERVICES="ldap:/// ldapi:/// ldaps:///"
```

sudo /etc/init.d/slapd restart

ldap:// + StartTLS should go to port 389. ldaps:// should be directed at port 636.

[Based on this](https://www.openldap.org/doc/admin24/tls.html)

This seems to be complicated. But here it goes. The configuration file is in `/etc/ldap/ldap.conf`.

Note, because we are using all pem formatted certificates you can concatenate the certs into one file. Ex.
```bash
cat site.pem ica.pem ca.pem > merged.pem
```

`TLSCACertificateFile` should contain a pem file with ALL the CAs slapd should trust. The CA that signed the server's certificate should be included in this file. So if the server's certificate was signed by an ICA this file should include
both the ICA and CA certs.

`TLSCACertificatePath` can point to a directory containing all the certificates in separate files. The one thing however is 
the directory must be managed by `openssh c_rehash`.

`TLSCertificateFile` should contain the server's certificate

`TLSCertificateKeyFile` should contain the server certificate's private key. This needs to be `chmod 400` for the user who runs slapd.

