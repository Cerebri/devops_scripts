#!/usr/bin/env bash

# Script to unlock a user

/usr/local/openvpn_as/scripts/confdba -mk vpn.server.lockout_policy.reset_time -v 1

/usr/local/openvpn_as/scripts/sacli start

sleep 2

/usr/local/openvpn_as/scripts/confdba -mk vpn.server.lockout_policy.reset_time -v 900

/usr/local/openvpn_as/scripts/sacli start