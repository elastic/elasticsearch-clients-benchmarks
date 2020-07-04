SHELL := /bin/bash


##@ Development
start: ## Start local server
	@node app.js

install: ## Install development dependencies
	@npm install

##@ Deployment
deploy-web: ## Deploy the website
	@{ \
		set -eu; \
		bin/deploy.sh; \
	}

deploy-api: ## Deploy the API to Google Cloud Functions
	@{ \
		set -eu; \
		gcloud functions deploy clients-benchmarks-proxy \
			--trigger-http \
			--allow-unauthenticated \
			--entry-point handler \
			--runtime nodejs10 \
			--source api/ \
			--memory 128MB \
			--service-account $$SERVICE_ACCOUNT_NAME \
			--set-env-vars ELASTICSEARCH_URL=$$(vault read -field reporting_url secret/clients-team/benchmarking) \
			--region europe-west3; \
	}

##@ Other
#------------------------------------------------------------------------------
help:  ## Display help
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
#------------- <https://suva.sh/posts/well-documented-makefiles> --------------

.DEFAULT_GOAL := help
.PHONY: start install
