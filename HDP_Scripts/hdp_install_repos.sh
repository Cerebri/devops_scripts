#!/usr/bin/env bash

# Get script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cp ${DIR}/*.repo /etc/yum.repos.d/