#!/bin/bash

yum -y install openldap-servers openldap-clients
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG

chown ldap. /var/lib/ldap/DB_CONFIG

/etc/rc.d/init.d/slapd start

chkconfig slapd on

slappasswd

echo "
# vi chrootpw.ldif
# specify the password generated above for "olcRootPW" section

dn: olcDatabase={0}config,cn=config
changetype: modify
add: olcRootPW
olcRootPW: {SSHA}xxxxxxxxxxxxxxxxxxxxxxxx "

ldapadd -Y EXTERNAL -H ldapi:/// -f chrootpw.ldif

# generate directory manager's password

slappasswd

echo "
# replace to your own domain name for "dc=***,dc=***" section

# specify the password generated above for "olcRootPW" section

dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth"
  read by dn.base="cn=Manager,dc=server,dc=world" read by * none

dn: olcDatabase={2}bdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=server,dc=world

dn: olcDatabase={2}bdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=Manager,dc=server,dc=world

dn: olcDatabase={2}bdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: {SSHA}xxxxxxxxxxxxxxxxxxxxxxxx

dn: olcDatabase={2}bdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange by
  dn="cn=Manager,dc=server,dc=world" write by anonymous auth by self write by * none
olcAccess: {1}to dn.base="" by * read
olcAccess: {2}to * by dn="cn=Manager,dc=server,dc=world" write by * read "

ldapmodify -Y EXTERNAL -H ldapi:/// -f chdomain.ldif

echo "[root@dlp ~]# vi basedomain.ldif
# replace to your own domain name for "dc=***,dc=***" section

dn: dc=server,dc=world
objectClass: top
objectClass: dcObject
objectclass: organization
o: Server World
dc: Server

dn: cn=Manager,dc=server,dc=world
objectClass: organizationalRole
cn: Manager
description: Directory Manager

dn: ou=People,dc=server,dc=world
objectClass: organizationalUnit
ou: People

dn: ou=Group,dc=server,dc=world
objectClass: organizationalUnit
ou: Group "

ldapadd -x -D cn=Manager,dc=server,dc=world -W -f basedomain.ldif

# Enter LDAP Password: # directory manager's password



