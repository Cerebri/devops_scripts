#!/usr/bin/env bash

grep -v ^[[:space:]]*[#\;] $1 | grep -v '^$'