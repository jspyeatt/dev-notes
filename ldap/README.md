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
