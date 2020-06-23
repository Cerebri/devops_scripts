#!/usr/bin/env bash

# This script gets all the roles and clusteroles associated with a particular service account

kubectl get rolebinding,clusterrolebinding --all-namespaces -o jsonpath='{range .items[?(@.subjects[0].name=="${1}")]}[{.roleRef.kind},{.roleRef.name}]{end}'