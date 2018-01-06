#!/usr/bin/env bash

echo "transport_maps =  hash:/etc/postfix/transport" >> /etc/postfix/main.cf
echo "cerebri.com     smtp:cerebri-com.mail.protection.outlook.com" >> /etc/postfix/transport

postmap hash:/etc/postfix/transport
postfix reload