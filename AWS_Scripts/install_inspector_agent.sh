#!/usr/bin/env bash

cd /tmp
curl -O https://d1wk0tztpsntt1.cloudfront.net/linux/latest/install
curl -O https://d1wk0tztpsntt1.cloudfront.net/linux/latest/inspector.gpg
gpg --import inspector.gpg
curl -O https://d1wk0tztpsntt1.cloudfront.net/linux/latest/install.sig
chmod a+x /tmp/install
bash /tmp/install
