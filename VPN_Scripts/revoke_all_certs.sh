#!/usr/bin/env bash

# Script to revoke all certs for all users forcing them to re-logon

for i in $(/usr/local/openvpn_as/scripts/sacli EnumClients); do

  echo "Revoking certificate for ${i}"

done
