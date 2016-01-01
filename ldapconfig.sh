#/bin/bash

set -x 

echo '# specify the password generated above for "olcRootPW" section
 dn: olcDatabase={0}config,cn=config
changetype: modify
add: olcRootPW
olcRootPW: {SSHA}q2Y5Cm34ZaNanydqw8YrXoPlEoRmQtc1' | tee chrootpw.ldif

echo '# specify the password generated above for olcRootPW section
dn: olcDatabase={0}config,cn=config
changetype: modify
add: olcRootPW
olcRootPW: {SSHA}q2Y5Cm34ZaNanydqw8YrXoPlEoRmQtc1
echo "# replace to your own domain name for dc=***,dc=*** section
# specify the password generated above for olcRootPW section
 dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
  read by dn.base=cn=Manager,dc=nk,dc=solutions read by * none

dn: olcDatabase={2}bdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=nk,dc=solutions

dn: olcDatabase={2}bdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=Manager,dc=nk,dc=solutions

dn: olcDatabase={2}bdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: {SSHA}7RTbYTmN5sYkUdMB9SYfxfQ6fmjiqiCQ

dn: olcDatabase={2}bdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange by
  dn=cn=Manager,dc=nk,dc=solutions write by anonymous auth by self write by * none
olcAccess: {1}to dn.base= by * read
olcAccess: {2}to * by dn=cn=Manager,dc=nk,dc=solutions write by * read' | tee chdomain.ldif

echo '# replace to your own domain name for dc=***,dc=*** section
dn: dc=nk,dc=solutions
objectClass: top
objectClass: dcObject
objectclass: organization
o: nk solutions
dc: nk

dn: cn=Manager,dc=nk,dc=solutions
objectClass: organizationalRole
cn: Manager
description: Directory Manager

dn: ou=People,dc=nk,dc=solutions
objectClass: organizationalUnit
ou: People

dn: ou=Group,dc=nk,dc=solutions
objectClass: organizationalUnit
ou: Group' | tee basedomain.ldif

echo '# create new user1
# replace to your own domain name for "dc=***,dc=***" section
dn: uid=cent,ou=People,dc=nk,dc=solutions
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
cn: Cent
sn: Linux
userPassword: {SSHA}}WX3DcCjx4QBeeXGU0slw+I0K2FIFxIyo
loginShell: /bin/bash
uidNumber: 1000
gidNumber: 1000
homeDirectory: /home/cent

dn: cn=cent,ou=Group,dc=nk,dc=solutions
objectClass: posixGroup
cn: Cent
gidNumber: 1000
memberUid: cent' | tee ldapuser.ldif
