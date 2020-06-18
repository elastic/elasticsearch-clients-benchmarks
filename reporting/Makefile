SHELL := /bin/bash

setup: stack status wait_for_elasticsearch setup_elasticsearch wait_for_kibana setup_kibana

clean:
	@docker-compose down --volumes

stack:
	@docker-compose up --detach

status:
	@{ \
		cols=`tput cols`; max=98; i=1; \
		while [[ "$$i" -lt "$$cols" && "$$i" -lt "$$max" ]]; do printf '-'; let i=$$i+1; done; printf "\n"; \
		docker-compose ps; \
		i=1; while [[ "$$i" -lt "$$cols" && "$$i" -lt "$$max" ]]; do printf '-'; let i=$$i+1; done; printf "\n"; \
	}

wait_for_elasticsearch:
	@{ \
		printf "Waiting for Elasticsearch..."; \
		until docker inspect elasticsearch-reporting > /dev/null 2>&1 && [[ `docker inspect -f '{{ .State.Health.Status }}' elasticsearch-reporting` == "healthy" ]]; do printf '.'; sleep 5; done; \
		echo ""; \
	}

wait_for_kibana:
	@{ \
		printf "Waiting for Kibana..."; \
		until docker inspect kibana-reporting > /dev/null 2>&1 && [[ `docker inspect -f '{{ .State.Health.Status }}' kibana-reporting` == "healthy" ]]; do printf '.'; sleep 5; done; \
		echo ""; \
	}

setup_elasticsearch:
	$(eval commands = "bash setup/scripts/put_metrics_intake_index_template.sh" "bash setup/scripts/put_metrics_results_index_template.sh" "bash setup/scripts/put_metrics_results_transform.sh")
ifndef DEBUG
	$(eval output = "> /dev/null")
endif
	@{ \
		export ELASTICSEARCH_URL=http://localhost:29200; \
		export TRANSFORM_FREQUENCY=10s; \
		export TRANSFORM_DELAY=0s; \
		\
		for command in $(commands); do \
			if [[ -n $$DEBUG ]]; then \
				printf "\033[1m$$command\033[0m\n------------------------------------------------------------------------------------------------\n"; \
			fi; \
			bash -c "$$command $(output)"; \
			status=$$?; \
			if [[ $$status != "0" ]]; then \
				printf "\033[0;31mError running command \033[1;31m$$command\033[0;31m; re-run with DEBUG=y to inspect the HTTP response.\033[0m\n"; \
				exit $$status; \
			fi; \
			if [[ -n $$DEBUG ]]; then \
				printf "\n"; \
			fi; \
		done; \
	}

setup_kibana:
ifdef DEBUG
	$(eval curl_flags = "-i")
	$(eval output = "")
else
	$(eval curl_flags = "-f")
	$(eval output = "> /dev/null")
endif
	@{ \
		bash -c "curl $(curl_flags) -ksS -X POST -H 'kbn-xsrf: true' 'http://localhost:5601/api/saved_objects/_import?overwrite=true' --form file=@kibana/export.ndjson $(output)"; \
		status=$$?; \
		if [[ $$status != "0" ]]; then \
			printf "\033[0;31mError loading Kibana dashboard; re-run with DEBUG=y to inspect the HTTP response.\033[0m\n"; \
		exit $$status; \
		fi; \
		if [[ -n $$DEBUG ]]; then \
			printf "\n\n"; \
		fi; \
	  printf "Open dashboard at <http://localhost:5601/app/kibana#/dashboard/77ea9ee0-7e36-11ea-9eb0-e7f97727999f>\n"; \
	}

.PHONY: setup clean stack status wait_for_elasticsearch wait_for_kibana setup_elasticsearch setup_kibana
