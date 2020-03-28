# Elasticsearch Clients Benchmarks

## Create the infrastructure

```bash
# TODO: Get the service account from Vault

export GOOGLE_CLOUD_KEYFILE_JSON=/.../elastic-clients-123def456.json

cd terraform/gcp
terraform plan -var client_repository_url=https://github.com/elastic/go-elasticsearch
terraform apply -var client_repository_url=https://github.com/elastic/go-elasticsearch
```
