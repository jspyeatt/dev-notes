# Openssl cert notes

## create-root-ca.sh
Creates a root certificate. It uses the extensions defined in openss-root.cnf. The resulting
certificates can be found in /tmp/certs/rootCA.

## create-intermediate
Creates an intermediate certificate using the root certificate created with create-root-ca.sh

Note, when you create an intermediate cert from the root certificate a copy of the intermediate
certificate ends up in the rootCA/newcerts directory. So you cannot create another intermeidate
certificate with the same common name.
