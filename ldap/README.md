# LDAP

A lot of this is based on https://likegeeks.com/linux-ldap-server/

## Installation

```bash
sudo apt-get install slapd
sudo apt-get install ldap-utils

# if you want to enable it at startup
sudo systemctl enable slapd
```
After installation, create an admin password
```bash
ldappasswd
```

The configuration files for ldap are in `/etc/openldap/slapd.d`

