#!/usr/bin/env bash

cmd="sudo cat /etc/kubernetes/azure.json | grep Secret | grep -v sudo"

while read ip; do echo -n "$ip : "; ssh -q -o StrictHostKeyChecking=no kubeuser@$ip "$cmd" </dev/null; done < <(kubectl get no -o jsonpath='{range.items[*].status.addresses[?(@.type=="InternalIP")]}{.address}{"\n"}{end}')