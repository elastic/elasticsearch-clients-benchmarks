#!/usr/bin/env bash

sudo su -

# ----- Add the "runner" user
useradd -d /home/runner -k /etc/skel -m -s /bin/bash -U runner
echo "Defaults:runner !requiretty" > /etc/sudoers.d/runner
echo "runner ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers.d/runner

# ----- Configure system limits
swapoff -a
sysctl -w vm.swappiness=1
sysctl -w fs.file-max=262144
sysctl -w vm.max_map_count=262144
cat >> /etc/security/limits.conf <<EOF
elasticsearch - memlock unlimited
elasticsearch - nofile  500000
elasticsearch - nproc   unlimited
EOF
systemctl disable fstrim
systemctl stop fstrim
echo "always" > /sys/kernel/mm/transparent_hugepage/enabled
echo "always" > /sys/kernel/mm/transparent_hugepage/defrag

# ----- Download metadata about the commit
curl -sSL --retry 10 --retry-max-time 30 https://api.github.com/repos/elastic/${client_name}/commits/${client_commit} > /home/runner/commit.json

# ----- Export information about the runner environment
cat >> /home/runner/environment.sh <<EOF
export BUILD_ID='${build_id}'

export DATA_SOURCE='${data_source}'

export CLIENT_IMAGE='${client_image}'
export CLIENT_NAME='${client_name}'
export CLIENT_COMMIT='${client_commit}'

export TARGET_SERVICE_TYPE='${target_service_type}'
export TARGET_SERVICE_NAME='${target_service_name}'
export TARGET_SERVICE_VERSION='${target_service_version}'
export TARGET_SERVICE_OS_FAMILY='${target_service_os_family}'

export ELASTICSEARCH_TARGET_URL='${target_urls}'

export CLOUD_PROVIDER='${cloud_provider}'
export CLOUD_REGION='${cloud_region}'
export CLOUD_ZONE='${cloud_zone}'
export CLOUD_INSTANCE_NAME='${cloud_instance_name}'
export CLOUD_MACHINE_TYPE='${cloud_machine_type}'
EOF
chown -R runner:runner /home/runner/*

# ----- Install additional packages
apt-get update --fix-missing
apt-get install jq --yes

# ----- Install Docker
apt-get install --yes apt-transport-https ca-certificates gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get install --yes docker-ce docker-ce-cli containerd.io
usermod -aG docker runner
newgrp docker

# ----- Configure access to Google Container Registry
ln -s /snap/google-cloud-sdk/current/bin/docker-credential-gcloud /usr/local/bin/
gcloud auth configure-docker eu.gcr.io --quiet
# TODO: This shouldn't be needed...
gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://eu.gcr.io

# ----- Pull the client Docker image
docker pull ${client_image}

# ----- Pull the Docker image with sample data
docker pull eu.gcr.io/elastic-clients/benchmarks-data
docker create --name benchmarks-data --volume /benchmarks-data --name benchmarks-data eu.gcr.io/elastic-clients/benchmarks-data /bin/true
