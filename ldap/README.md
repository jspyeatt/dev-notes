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

## Configuring for Secure Connections
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

