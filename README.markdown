# Elasticsearch Clients Benchmarks

[![Terraform](https://github.com/elastic/elasticsearch-clients-benchmarks/workflows/Terraform/badge.svg)](https://github.com/elastic/elasticsearch-clients-benchmarks/actions?query=workflow%3ATerraform)
[![Shellcheck](https://github.com/elastic/elasticsearch-clients-benchmarks/workflows/Shellcheck/badge.svg)](https://github.com/elastic/elasticsearch-clients-benchmarks/actions?query=workflow%3AShellcheck)

## Create the infrastructure and run client benchmarks

```bash
# TODO: Get the service account from Vault
export GOOGLE_CLOUD_KEYFILE_JSON=/.../elastic-clients-123def456.json
export ELASTICSEARCH_REPORT_URL=https://...@...gcp.cloud.es.io:9243
export ELASTICSEARCH_REPORT_PASSWORD=...

export TF_VAR_reporting_url="$ELASTICSEARCH_REPORT_URL"
export TF_VAR_reporting_password="$ELASTICSEARCH_REPORT_PASSWORD"

export CLIENT_IMAGE="eu.gcr.io/elastic-clients/go-elasticsearch:0db2532f"

cd terraform/gcp
terraform init
terraform plan --var client_image="$CLIENT_IMAGE"
terraform apply --var client_image="$CLIENT_IMAGE"

gcloud compute --project 'elastic-clients' ssh $(terraform output runner_instance_name) \
  --zone 'europe-west1-b' \
  --command="curl -s '$(terraform output --json cluster_urls | jq -r '.[0]')/_cat/nodes?v&h=name,ip,master'"

# > name   ip       master
# > es-001 10.0.0.2 *

gcloud compute --project 'elastic-clients' ssh $(terraform output runner_instance_name) \
  --zone='europe-west1-b' \
  --ssh-flag='-t' \
  --command="\
  CLIENT_BRANCH=master \
  CLIENT_BENCHMARK_ENVIRONMENT=production \
  /home/runner/runner.sh \
  'source /environment.sh && cd _benchmarks/benchmarks && FILTER=info go run cmd/main.go'"

# > Running benchmarks for go-elasticsearch@8.0.0-SNAPSHOT; linux/go1.14
# >  [ping]          1000×     mean=0s runner=success report=success
# >  ...

export CLIENT_IMAGE="eu.gcr.io/elastic-clients/elasticsearch-ruby:7a069e0e"

terraform apply --var client_image="$CLIENT_IMAGE"

gcloud compute --project 'elastic-clients' ssh $(terraform output runner_instance_name) \
  --zone='europe-west1-b' \
  --ssh-flag='-t' \
  --command="\
  CLIENT_BRANCH=master \
  CLIENT_BENCHMARK_ENVIRONMENT=production \
  /home/runner/runner.sh \
  '. /environment.sh && cd /elasticsearch-ruby/benchmarks && bundle exec ruby bin/run.rb'"

# > Running benchmarks for elasticsearch-ruby@8.0.0.pre
# >  [ping]          1000x     mean=1ms runner=success report=success
# > ...

terraform destroy --var client_image="$CLIENT_IMAGE"
```

-----

```
TODO: Documentation
```
