#!/usr/bin/env bash

if [[ -z $ELASTICSEARCH_URL ]]; then
  echo -e "\033[31;1mERROR:\033[0m Required environment variable [ELASTICSEARCH_URL] not set\033[0m"; exit 1
fi

if [[ ! -z $FORCE ]]; then
  curl -ksS -X POST "$ELASTICSEARCH_URL/_transform/metrics-results/_stop?pretty"
  curl -ksS -X DELETE "$ELASTICSEARCH_URL/_transform/metrics-results?pretty"
  curl -ksS -X DELETE "$ELASTICSEARCH_URL/metrics-results?pretty"
fi

curl -ksS -X PUT "$ELASTICSEARCH_URL/_transform/metrics-results?pretty" -H 'Content-Type: application/json' -d'
{
  "source": {
    "index": [
      "metrics-intake*"
    ]
  },
  "dest": {
    "index": "metrics-results"
  },
  "pivot": {
    "group_by": {
      "build_id": {
        "terms": {
          "field": "benchmark.build_id"
        }
      },

      "action": {
        "terms": {
          "field": "event.action"
        }
      },

      "@timestamp": {
        "date_histogram": {
          "field": "@timestamp",
          "calendar_interval": "1h"
        }
      },

      "client.name": {
        "terms": {
          "field": "benchmark.runner.service.name"
        }
      },
      "client.version": {
        "terms": {
          "field": "benchmark.runner.service.version"
        }
      },
      "client.git.branch": {
        "terms": {
          "field": "benchmark.runner.service.git.branch"
        }
      },
      "client.git.commit": {
        "terms": {
          "field": "benchmark.runner.service.git.commit"
        }
      },
      "client.runtime.name": {
        "terms": {
          "field": "benchmark.runner.runtime.name"
        }
      },
      "client.runtime.version": {
        "terms": {
          "field": "benchmark.runner.runtime.version"
        }
      },

      "target.name": {
        "terms": {
          "field": "benchmark.target.service.name"
        }
      },
      "target.version": {
        "terms": {
          "field": "benchmark.target.service.version"
        }
      }
    },
    "aggregations": {
      "duration.avg": {
        "avg": {
          "field": "event.duration"
        }
      },
      "duration.min": {
        "min": {
          "field": "event.duration"
        }
      },
      "duration.max": {
        "max": {
          "field": "event.duration"
        }
      }
    }
  },
  "sync": {
    "time": {
      "field": "@timestamp"
    }
  }
}
'

curl -ksS -X PUT "$ELASTICSEARCH_URL/metrics-results?pretty"
curl -ksS -X POST "$ELASTICSEARCH_URL/_transform/metrics-results/_start?pretty"
