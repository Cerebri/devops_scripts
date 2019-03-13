#!/usr/bin/env bash

wget https://raw.githubusercontent.com/jupyter-incubator/enterprise_gateway/master/etc/kubernetes/enterprise-gateway.yaml

kubectl apply -f enterprise-gateway.yaml

