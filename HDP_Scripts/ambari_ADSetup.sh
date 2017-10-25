#!/usr/bin/env bash

## Simply preloading the ambari config with Active Directory
##   compatible settings.
##
## You'll need to update the 1st 3 settings.
##
## Then execute:
##   sudo ambari-server setup-ldap
##   sudo ambari-server restart
##   sudo ambari-agent restart
##   sudo ambari-server sync-ldap --all


cat <<-'EOF' | sudo tee -a /etc/ambari-server/conf/ambari.properties
authentication.ldap.baseDn=DC=cerebri,DC=com
authentication.ldap.managerDn=CN=LDAPS User,OU=ServiceUsers,DC=cerebri,DC=com
authentication.ldap.primaryUrl=10.1.0.7:636
authentication.ldap.bindAnonymously=false
authentication.ldap.dnAttribute=distinguishedName
authentication.ldap.groupMembershipAttr=member
authentication.ldap.groupNamingAttr=cn
authentication.ldap.groupObjectClass=group
authentication.ldap.useSSL=true
authentication.ldap.userObjectClass=user
authentication.ldap.usernameAttribute=sAMAccountName
EOF