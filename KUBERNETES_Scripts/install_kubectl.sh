#!/usr/bin/env bash

apt-get update && apt-get install -y apt-transport-https

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list

apt-get update

apt-get install -y kubectl bash-completion

echo 'source <(kubectl completion bash)' >> /etc/profile

kubectl completion bash >/etc/bash_completion.d/kubectl

curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash