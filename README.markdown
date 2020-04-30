# Elasticsearch Clients Benchmarks

[![Terraform](https://github.com/elastic/elasticsearch-clients-benchmarks/workflows/Terraform/badge.svg)](https://github.com/elastic/elasticsearch-clients-benchmarks/actions?query=workflow%3ATerraform)
[![Shellcheck](https://github.com/elastic/elasticsearch-clients-benchmarks/workflows/Shellcheck/badge.svg)](https://github.com/elastic/elasticsearch-clients-benchmarks/actions?query=workflow%3AShellcheck)

Benchmarking framework for Elasticsearch clients.

## Introduction

This repository contains all neccessary tooling for benchmarking the [Elasticsearch clients](https://www.elastic.co/guide/en/elasticsearch/client/index.html).

It uses [_Terraform_](https://www.terraform.io) to create a fully configured infrastructure for running the benchmarks, includes the JSON data for benchmarks, and provides scripts to setup the reporting Elasticsearch cluster and Kibana dashboards.

## Usage

You need to install [_Terraform_](https://learn.hashicorp.com/terraform/getting-started/install.html#install-terraform) and the [_Google Cloud Platform SDK_](https://cloud.google.com/sdk/docs/downloads-interactive) to create and interact with the infrastructure; please follow the respective guidelines.

On Mac OS X, you can install them via _Homebrew_:

```bash
brew install terraform
brew cask install google-cloud-sdk
```

Clone this repository:

```bash
git clone https://github.com/elastic/elasticsearch-clients-benchmarks.git
cd elasticsearch-clients-benchmarks
```

To create the infrastructure in Google Cloud Platform (GCP), you need to export an environment variable pointing to a file with a [service account](https://cloud.google.com/iam/docs/creating-managing-service-account-keys):

```bash
export GOOGLE_CLOUD_KEYFILE_JSON=/.../foo-123def456.json
```

You need to export environment variables with the reporting Elasticsearch cluster URL and credentials, which are consumed by _Terraform_:

```bash
export TF_VAR_reporting_url='http://localhost:9200'
export TF_VAR_reporting_username='username'
export TF_VAR_reporting_password='password'
```

You need to export an environment variable with the fully-qualified client Docker image:

```bash
export CLIENT_IMAGE="docker.elastic.co/clients/go-elasticsearch:d3adb33f"
```

> NOTE: The value is illustrative; see [https://container-library.elastic.co/r/clients/go-elasticsearch](https://container-library.elastic.co/r/clients/go-elasticsearch) for a list of images.

To create the infrastructure with the default settings, run the _Terraform_ commands:

```bash
cd terraform/gcp
terraform init
terraform apply --var client_image="$CLIENT_IMAGE"
```

After the `apply` command finishes, verify that the runner instance is able to communicate with the target instance:

```bash
gcloud compute --project 'elastic-clients' ssh $(terraform output runner_instance_name) \
  --zone 'europe-west1-b' \
  --command="curl -s '$(terraform output --json cluster_urls | jq -r '.[0]')/_cat/nodes?v&h=name,ip,master'"
# > name   ip       master
# > es-001 10.0.0.2 *
```

In order to run the client benchmarks, execute them over an SSH connection:

```bash
gcloud compute --project 'elastic-clients' ssh $(terraform output runner_instance_name) \
  --zone='europe-west1-b' \
  --ssh-flag='-t' \
  --command="\
  CLIENT_BRANCH=master \
  CLIENT_BENCHMARK_ENVIRONMENT=development \
  /home/runner/runner.sh \
  'source /environment.sh && cd _benchmarks/benchmarks && go run cmd/main.go'"
# > Running benchmarks for go-elasticsearch@8.0.0-SNAPSHOT; linux/go1.14
# >  [ping]          1000×     mean=0s runner=success report=success
# >  ...
```

When you're finished running the benchmarks, destroy the infrastructure:

```bash
terraform destroy --var client_image="$CLIENT_IMAGE"
```

## License

(c) 2020 Elasticsearch B.V. Licensed under the Apache License, Version 2.0.
