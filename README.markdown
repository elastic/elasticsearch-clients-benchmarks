# Elasticsearch Clients Benchmarks

## Create the infrastructure

```bash
# TODO: Get the service account from Vault

export GOOGLE_CLOUD_KEYFILE_JSON=/.../elastic-clients-123def456.json

cd terraform/gcp
terraform plan --var client_repository_url=https://github.com/elastic/go-elasticsearch --var server_count=3
terraform apply --var client_repository_url=https://github.com/elastic/go-elasticsearch --var server_count=3

gcloud compute --project 'elastic-clients' ssh $(terraform output --json server_instance_names | jq -r '.[0]') --command='curl -s http://localhost:9200/_cat/nodes?v'

terraform destroy --var client_repository_url=https://github.com/elastic/go-elasticsearch
```
