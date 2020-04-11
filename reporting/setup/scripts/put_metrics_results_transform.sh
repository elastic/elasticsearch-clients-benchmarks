#!/usr/bin/env bash

if [[ -z $ELASTICSEARCH_URL ]]; then
  echo -e "\033[31;1mERROR:\033[0m Required environment variable [ELASTICSEARCH_URL] not set\033[0m"; exit 1
fi

curl -k -X PUT "$ELASTICSEARCH_URL/_transform/metrics-results?pretty" -H 'Content-Type: application/json' -d'
{
  "source": {
    "index": [
      "metrics-intake*"
    ]
  },
  "pivot": {
    "group_by": {
      "action": {
        "terms": {
          "field": "event.action"
        }
      },
      "client.name": {
        "terms": {
          "field": "benchmark.runner.service.name"
        }
      },
      "@timestamp": {
        "date_histogram": {
          "field": "@timestamp",
          "calendar_interval": "1h"
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
  "dest": {
    "index": "metrics-results"
  },
  "sync": {
    "time": {
      "field": "@timestamp",
      "delay": "60s"
    }
  }
}
'

curl -k -X PUT "$ELASTICSEARCH_URL/metrics-results?pretty"

curl -k -X POST "$ELASTICSEARCH_URL/_transform/metrics-results/_start?pretty"
