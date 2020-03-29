# Elasticsearch Clients Benchmarks

## Create the infrastructure

```bash
# TODO: Get the service account from Vault
export GOOGLE_CLOUD_KEYFILE_JSON=/.../elastic-clients-123def456.json

cd terraform/gcp
terraform plan --var client_image=eu.gcr.io/elastic-clients/go-elasticsearch:3a5eff96 --var node_count=3
terraform apply --var client_image=eu.gcr.io/elastic-clients/go-elasticsearch:3a5eff96 --var node_count=3

gcloud compute --project 'elastic-clients' ssh $(terraform output runner_instance_name) --command="curl -s '$(terraform output --json cluster_urls | jq -r '.[0]')/_cat/nodes?v&h=name,ip,master'"

gcloud compute --project 'elastic-clients' ssh $(terraform output runner_instance_name) --command="sudo su - runner -c 'docker run --env ELASTICSEARCH_URL=$(terraform output --json cluster_urls | jq -r '.[0]') $(terraform output client_image) go run _examples/main.go'"

terraform destroy --var client_image=eu.gcr.io/elastic-clients/go-elasticsearch:3a5eff96
```
