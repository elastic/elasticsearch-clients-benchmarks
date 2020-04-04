# Elasticsearch Clients Benchmarks

## Create the infrastructure and run client benchmarks

```bash
# TODO: Get the service account from Vault
export GOOGLE_CLOUD_KEYFILE_JSON=/.../elastic-clients-123def456.json
export ELASTICSEARCH_REPORT_URL=https://...@...gcp.cloud.es.io:9243

export CLIENT_IMAGE="eu.gcr.io/elastic-clients/go-elasticsearch:455295f9"

cd terraform/gcp
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
  --command="sudo su - runner -c '\
  docker run -it --rm \
    --env ELASTICSEARCH_TARGET_URL=$(terraform output --json cluster_urls | jq -r '.[0]') \
    --env ELASTICSEARCH_REPORT_URL=$(echo $ELASTICSEARCH_REPORT_URL) \
    --env DATA_SOURCE=/benchmarks-data \
    --volumes-from \"benchmarks-data\" \
    $CLIENT_IMAGE \
    /bin/sh -c \"cd _benchmarks/runner && go run main.go\"'"

# > Running benchmarks for go-elasticsearch@8.0.0-SNAPSHOT; linux/go1.14
# >  [ping]          1000×     mean=0s runner=success report=success
# >  ...

export CLIENT_IMAGE="eu.gcr.io/elastic-clients/elasticsearch-ruby:e08bb8ee"

terraform apply --var client_image="$CLIENT_IMAGE"

gcloud compute --project 'elastic-clients' ssh $(terraform output runner_instance_name) \
  --zone='europe-west1-b' \
  --ssh-flag='-t' \
  --command="sudo su - runner -c '\
  docker run -it --rm \
    --env ELASTICSEARCH_TARGET_URL=$(terraform output --json cluster_urls | jq -r '.[0]') \
    --env ELASTICSEARCH_REPORT_URL=$(echo $ELASTICSEARCH_REPORT_URL) \
    --env DATA_SOURCE=/benchmarks-data \
    --volumes-from \"benchmarks-data\" \
    $CLIENT_IMAGE \
    /bin/sh -c \"cd benchmarks && bundle exec ruby run.rb\"'"

# > Running benchmarks for elasticsearch-ruby@8.0.0.pre
# >  [ping]          1000x     mean=1ms runner=success report=success
# > ...

terraform destroy --var client_image="$CLIENT_IMAGE"
```

-----

```
TODO: Documentation
```
