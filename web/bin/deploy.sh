#!/usr/bin/env bash

#
# Licensed to Elasticsearch B.V. under one or more contributor license
# agreements. See the NOTICE file distributed with this work for additional
# information regarding copyright ownership. Elasticsearch B.V. licenses this
# file to you under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#	http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.
#

set -e

# This script runs a docker container, where it executes itself to deploy to GCP.

# Usage:
# * Compile and deploy:          ./web/bin.deploy.sh
# * Deploy only without docker:  ./web/bin.deploy.sh nodocker

# Expected env variables:
# * GCE_ACCOUNT - credentials for the google service account (JSON blob)
# * optional pull_request_id - the ID of the github pull request if not a branch merge

if [[ -z "${GCE_ACCOUNT}" ]]; then
  echo "GCE_ACCOUNT is not set. Expected Google service account JSON blob."
  exit 1
fi

# In some cases Jenkins might not expand the pull request variable correctly
# See "export pull_request_id={ghprbPullId}" in /.ci/jobs/defaults.yml
if [[ "${pull_request_id:-}" == "{ghprbPullId}" ]]; then
  unset pull_request_id
fi

# https://stackoverflow.com/a/9107028/177275
WEB_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

post_comment_to_gh()
{
  local PR_ID=$1
  if [[ -z "${GITHUB_TOKEN}" ]]; then
    echo "Warning: GITHUB_TOKEN is not set; cannot publish PR docs preview URL to Github."
  else
    printf '\nAdding comment to GitHub Pull Request: %i\n' "$PR_ID"

    comment="Preview documentation changes for this PR: https://clients-benchmarks.elastic.co/pr_$PR_ID/"

    set +x
    curl \
      --silent \
      --location \
      --header "Authorization: token ${GITHUB_TOKEN}" \
      --request POST \
      --data "$(jq --null-input --arg comment "$comment" '{ body: $comment }')" \
      "https://api.github.com/repos/elastic/elasticsearch-clients-benchmarks/issues/${PR_ID}/comments"
  fi
}

publish_to_bucket()
{
  local full_bucket_path="$1"
  local max_age="$2"

  echo "Copying $WEB_PATH/public/* to $full_bucket_path"
  gsutil -m \
    -h "Cache-Control:public, max-age=$max_age" \
    cp \
    -r \
    -a public-read \
    -z js,css,html \
    "$WEB_PATH/public/*" "$full_bucket_path"
}

if [[ "$1" != "nodocker" ]]; then
  # Run this script from inside the docker container, using google/cloud-sdk image
  echo "Deploying to bucket"
  docker run \
    --rm -i \
    --env GCE_ACCOUNT \
    --env pull_request_id \
    --env HOME=/tmp \
    --volume "$WEB_PATH:/app" \
    --user="$(id -u):$(id -g)" \
    --workdir /app \
    'google/cloud-sdk:slim' \
    /app/bin/deploy.sh nodocker "$@"
  unset GCE_ACCOUNT

  if [[ -n "${pull_request_id:-}" ]]; then
    post_comment_to_gh "${pull_request_id}"
  fi
  unset GITHUB_TOKEN
else
  # Copying files to the bucket
  # Login to the cloud with the service account
  gcloud auth activate-service-account --key-file <(echo "$GCE_ACCOUNT")
  unset GCE_ACCOUNT

  # Copy files
  BUCKET="elastic-bekitzur-clients-benchmarks-live"
  if [[ -n "${pull_request_id:-}" ]]; then
    publish_to_bucket "gs://$BUCKET/pr_${pull_request_id}/" "1800"
  else
    publish_to_bucket "gs://$BUCKET/" "604800"
  fi
fi
