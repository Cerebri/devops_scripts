#!/usr/bin/env bash

# Call script with username to reset Google Authenticator for the user

/usr/local/openvpn_as/scripts/sacli -u $1 GoogleAuthRegen