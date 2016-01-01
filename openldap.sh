#!/bin/bash

set -x 

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

which wget >/dev/null 2>&1
if  [ $? != 0 ]; then
  yum install wget >/dev/null 2>&1
fi

yum -y install openldap-servers openldap-clients

cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG

chown ldap. /var/lib/ldap/DB_CONFIG

/etc/rc.d/init.d/slapd start

chkconfig slapd on

# Downloda ldapconfig script

cd /tmp

wget https://raw.githubusercontent.com/naveenlj/openldap/master/ldapconfig.sh

chmod +x ldapconfig.sh

bash ldapconfig.sh

ldapadd -Y EXTERNAL -H ldapi:/// -f chrootpw.ldif

ldapmodify -Y EXTERNAL -H ldapi:/// -f chdomain.ldif

# Change dc,dc according to ldapconfig file

ldapadd -x -D cn=Manager,dc=nk,dc=solutions -W -f basedomain.ldif

ldapadd -x -D cn=Manager,dc=server,dc=world -W -f ldapuser.ldif 

wget https://raw.githubusercontent.com/naveenlj/openldap/master/ldap-user.sh

chmod +x ldap-user.sh

bash ldap-user.sh

echo " ldap password : ldap "
ldapadd -x -D cn=Manager,dc=nk,dc=solutions -W -f ldapuser.ldif

cd ..



