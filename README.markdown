# Elasticsearch Clients Benchmarks

## Create the infrastructure

```bash
# TODO: Get the service account from Vault

export GOOGLE_CLOUD_KEYFILE_JSON=/.../elastic-clients-123def456.json

cd terraform/gcp
terraform plan --var client_repository_url=https://github.com/elastic/go-elasticsearch --var node_count=3
terraform apply --var client_repository_url=https://github.com/elastic/go-elasticsearch --var node_count=3

gcloud compute --project 'elastic-clients' ssh $(terraform output runner_instance_name) --command="curl -s '$(terraform output --json cluster_urls | jq -r '.[0]')/_cat/nodes?v&h=name,ip,master'"

terraform destroy --var client_repository_url=https://github.com/elastic/go-elasticsearch
```
