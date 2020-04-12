# Elasticsearch Clients Benchmarks

## Create the infrastructure and run client benchmarks

```bash
# TODO: Get the service account from Vault
export GOOGLE_CLOUD_KEYFILE_JSON=/.../elastic-clients-123def456.json
export ELASTICSEARCH_REPORT_URL=https://...@...gcp.cloud.es.io:9243
export ELASTICSEARCH_REPORT_PASSWORD=...

export CLIENT_IMAGE="eu.gcr.io/elastic-clients/go-elasticsearch:9c97913f"

cd terraform/gcp
terraform plan --var client_image="$CLIENT_IMAGE" --var 'reporting={"url": "$ELASTICSEARCH_REPORT_URL", "password": "$ELASTICSEARCH_REPORT_PASSWORD"}'
terraform apply --var client_image="$CLIENT_IMAGE" --var 'reporting={"url": "$ELASTICSEARCH_REPORT_URL", "password": "$ELASTICSEARCH_REPORT_PASSWORD"}'

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
    --env CLIENT_BRANCH=master \
    --env ELASTICSEARCH_REPORT_URL=$ELASTICSEARCH_REPORT_URL \
    --volume /home/runner/environment.sh:/environment.sh \
    --volumes-from \"benchmarks-data\" \
    $CLIENT_IMAGE \
    /bin/sh -c \"source /environment.sh && cd _benchmarks/runner && go run main.go\"'"

# > Running benchmarks for go-elasticsearch@8.0.0-SNAPSHOT; linux/go1.14
# >  [ping]          1000×     mean=0s runner=success report=success
# >  ...

export CLIENT_IMAGE="eu.gcr.io/elastic-clients/elasticsearch-ruby:b5764652"

terraform apply --var client_image="$CLIENT_IMAGE" --var 'reporting={"url": "$ELASTICSEARCH_REPORT_URL", "password": "$ELASTICSEARCH_REPORT_PASSWORD"}'

gcloud compute --project 'elastic-clients' ssh $(terraform output runner_instance_name) \
  --zone='europe-west1-b' \
  --ssh-flag='-t' \
  --command="sudo su - runner -c '\
  docker run -it --rm \
    --env CLIENT_BRANCH=master \
    --env ELASTICSEARCH_REPORT_URL=$ELASTICSEARCH_REPORT_URL \
    --volume /home/runner/environment.sh:/environment.sh \
    --volumes-from \"benchmarks-data\" \
    $CLIENT_IMAGE \
    /bin/sh -c \". /environment.sh && cd /elasticsearch-ruby/benchmarks && bundle exec ruby run.rb\"'"

# > Running benchmarks for elasticsearch-ruby@8.0.0.pre
# >  [ping]          1000x     mean=1ms runner=success report=success
# > ...

terraform destroy --var client_image="$CLIENT_IMAGE" --var 'reporting={"url": "$ELASTICSEARCH_REPORT_URL", "password": "$ELASTICSEARCH_REPORT_PASSWORD"}'
```

-----

```
TODO: Documentation
```
