# extract local users and groups who have 500-999 digit UID
# replace "SUFFIX=***" to your own domain name
# this is an example
 #!/bin/bash

SUFFIX='dc=server,dc=world'
LDIF='ldapuser.ldif'

echo -n > $LDIF
for line in `grep "x:[5-9][0-9][0-9]:" /etc/passwd | sed -e "s/ /%/g"`
do
    LUID="`echo $line | cut -d: -f1`"
    NAME="`echo $line | cut -d: -f5 | cut -d, -f1`"

    if [ ! "$NAME" ]
    then
        NAME="$LUID"
    else
        NAME=`echo "$NAME" | sed -e 's/%/ /g'`
    fi

    SN=`echo "$NAME" | awk '{print $2}'`
    [ ! "$SN" ] && SN="$NAME"

    LASTCHANGEFLAG=`grep $LUID: /etc/shadow | cut -d: -f3`
    [ ! "$LASTCHANGEFLAG" ] && LASTCHANGEFLAG="0"

    SHADOWFLAG=`grep $LUID: /etc/shadow | cut -d: -f9`
    [ ! "$SHADOWFLAG" ] && SHADOWFLAG="0"

    echo "dn: uid=$LUID,ou=People,$SUFFIX" >> $LDIF
    echo "objectClass: inetOrgPerson" >> $LDIF
    echo "objectClass: posixAccount" >> $LDIF
    echo "objectClass: shadowAccount" >> $LDIF
    echo "sn: $SN" >> $LDIF
    echo "givenName: `echo $NAME | awk '{print $1}'`" >> $LDIF
    echo "cn: $NAME" >> $LDIF
    echo "displayName: $NAME" >> $LDIF
    echo "uidNumber: `echo $line | cut -d: -f3`" >> $LDIF
    echo "gidNumber: `echo $line | cut -d: -f4`" >> $LDIF
    echo "userPassword: {crypt}`grep $LUID: /etc/shadow | cut -d: -f2`" >> $LDIF
    echo "gecos: $NAME" >> $LDIF
    echo "loginShell: `echo $line | cut -d: -f7`" >> $LDIF
    echo "homeDirectory: `echo $line | cut -d: -f6`" >> $LDIF
    echo "shadowExpire: `passwd -S $LUID | awk '{print $7}'`" >> $LDIF
    echo "shadowFlag: $SHADOWFLAG" >> $LDIF
    echo "shadowWarning: `passwd -S $LUID | awk '{print $6}'`" >> $LDIF
    echo "shadowMin: `passwd -S $LUID | awk '{print $4}'`" >> $LDIF
    echo "shadowMax: `passwd -S $LUID | awk '{print $5}'`" >> $LDIF
    echo "shadowLastChange: $LASTCHANGEFLAG" >> $LDIF
    echo >> $LDIF
done

for line in `grep "x:[5-9][0-9][0-9]:" /etc/group`
do
    CN="`echo $line | cut -d: -f1`"
    LGID="`echo $line | cut -d: -f3`"
    
    echo "dn: cn=$CN,ou=Group,$SUFFIX" >> $LDIF
    echo "objectClass: posixGroup" >> $LDIF
    echo "cn: $CN" >> $LDIF
    echo "gidNumber: $LGID" >> $LDIF
    echo "memberUid: `grep ":$LGID:" /etc/passwd | cut -d: -f1`" >> $LDIF

    users="`echo $line | cut -d: -f4`"
    if [ "$users" ]
    then
        for user in `echo "$users" | sed 's/,/ /g'`
        do
            [ ! "$CN" = "$user" ] && echo "memberUid: $user" >> $LDIF
        done
    fi
    echo >> $LDIF
done
