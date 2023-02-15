#!/usr/bin/env bash

# Make sure the objects are readable
sudo chmod -R go+r $1

# Make sure the directories are readable
find $1 -type d -exec chmod +x {} \;

# Count the files
echo $(find ${1} -type f | wc -l)

oci os object bulk-upload --src-dir $1 --bucket-name $2 --storage-tier InfrequentAccess --no-overwrite --parallel-upload-count 250