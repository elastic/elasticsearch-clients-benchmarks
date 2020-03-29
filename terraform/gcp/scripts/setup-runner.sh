#!/usr/bin/env bash

sudo su -

useradd -d /home/runner -k /etc/skel -m -s /bin/bash -U runner
echo "Defaults:runner !requiretty" > /etc/sudoers.d/runner
echo "runner ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers.d/runner

curl -sSL https://api.github.com/repos/elastic/${client_name}/commits/${client_commit} > /home/runner/commit.json

cat >> /home/runner/environment.sh <<EOF
export BUILD_ID='${build_id}'
export CLIENT_IMAGE='${client_image}'
export CLIENT_NAME='${client_name}'
export CLIENT_COMMIT='${client_commit}'
EOF

chown -R runner:runner /home/runner/*

curl -# -O https://dl.google.com/go/go1.14.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.14.linux-amd64.tar.gz

sudo su - runner
echo 'export PATH=$PATH:/usr/local/go/bin' >> /home/runner/.profile
source /home/runner/.profile
go version

apt-get update --fix-missing

apt-get install jq --yes

apt-get install --yes apt-transport-https ca-certificates gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get install --yes docker-ce docker-ce-cli containerd.io
usermod -aG docker runner
newgrp docker

gcloud auth configure-docker --quiet
sudo ln -s /snap/google-cloud-sdk/122/bin/docker-credential-gcloud /snap/bin/docker-credential-gcloud

docker pull ${client_image}
