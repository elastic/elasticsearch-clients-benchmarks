#!/usr/bin/env bash

set -eo pipefail

if [[ -z $ELASTICSEARCH_URL ]]; then
  echo -e "\033[31;1mERROR:\033[0m Required environment variable [ELASTICSEARCH_URL] not set\033[0m"; exit 1
fi

if [[ -n $DEBUG ]]; then
  flags="-i"
else
  flags="-f"
fi

if [[ -n $FORCE ]]; then
  curl $flags -ksS -X DELETE "$ELASTICSEARCH_URL/metrics-intake-*?pretty"
  curl $flags -ksS -X DELETE "$ELASTICSEARCH_URL/_template/metrics-intake?pretty"
fi

curl $flags -ksS -X PUT "$ELASTICSEARCH_URL/_template/metrics-intake?pretty" -H 'Content-Type: application/json' -d'
{
  "index_patterns": [
    "metrics-intake*"
  ],

  "settings": {
    "number_of_shards": 1
  },

  "mappings": {
    "_meta": { "version": "1.0" },
    "dynamic": "strict",
    "dynamic_templates": [
      {
        "labels": {
          "match_mapping_type": "string",
          "path_match": "labels.*",
          "mapping": {
            "type": "keyword"
          }
        }
      }
    ],

    "properties": {
      "@timestamp": { "type": "date" },
      "tags": { "type": "keyword" },
      "labels": { "type": "object", "dynamic": true },

      "event": {
        "properties": {
          "action": { "type": "keyword" },
          "duration": { "type": "long", "index": false },
          "dataset": { "type": "keyword" },
          "outcome": { "type": "keyword", "null_value": "unknown" }
        }
      },
      "http": {
        "properties": {
          "response": {
            "properties": {
              "status_code": { "type": "short" }
            }
          }
        }
      },
      "benchmark": {
        "properties": {
          "build_id": { "type": "keyword" },
          "category": { "type": "keyword" },
          "environment": { "type": "keyword" },
          "repetitions": { "type": "long", "null_value": 1, "index": false },
          "operations":  { "type": "long", "null_value": 1, "index": false },
          "runner": {
            "properties": {
              "os": {
                "properties": {
                  "family": { "type": "keyword" }
                }
              },
              "runtime": {
                "properties": {
                  "name": { "type": "keyword" },
                  "version": { "type": "keyword" }
                }
              },
              "service": {
                "properties": {
                  "name": { "type": "keyword" },
                  "type": { "type": "keyword" },
                  "version": { "type": "keyword" },
                  "git": {
                    "properties": {
                      "branch": { "type": "keyword" },
                      "commit": { "type": "keyword" }
                    }
                  }
                }
              }
            }
          },
          "target": {
            "properties": {
              "os": {
                "properties": {
                  "family": { "type": "keyword" }
                }
              },
              "service": {
                "properties": {
                  "name": { "type": "keyword" },
                  "type": { "type": "keyword" },
                  "version": { "type": "keyword" },
                  "git": {
                    "properties": {
                      "branch": { "type": "keyword" },
                      "commit": { "type": "keyword" }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
'
