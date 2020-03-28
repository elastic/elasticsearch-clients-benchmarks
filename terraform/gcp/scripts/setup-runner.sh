#!/usr/bin/env bash

sudo su -

useradd -d /home/runner -k /etc/skel -m -s /bin/bash -U runner
echo "Defaults:runner !requiretty" > /etc/sudoers.d/runner
echo "runner ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers.d/runner

curl -# -O https://dl.google.com/go/go1.14.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.14.linux-amd64.tar.gz

sudo su - runner
echo 'export PATH=$PATH:/usr/local/go/bin' >> /home/runner/.profile
source /home/runner/.profile
go version

cd /home/runner/
git clone ${client_repository_url}

chown -R runner:runner /home/runner/*
