#!/usr/bin/env bash

if [[ -z $ELASTICSEARCH_URL ]]; then
  echo -e "\033[31;1mERROR:\033[0m Required environment variable [ELASTICSEARCH_URL] not set\033[0m"; exit 1
fi

if [[ -n $FORCE ]]; then
  curl -ksS -X DELETE "$ELASTICSEARCH_URL/_template/metrics-results?pretty"
  curl -ksS -X DELETE "$ELASTICSEARCH_URL/metrics-results?pretty"
  curl -ksS -X POST "$ELASTICSEARCH_URL/_transform/metrics-results/_stop?pretty"
fi

curl -k -X PUT "$ELASTICSEARCH_URL/_template/metrics-results?pretty" -H 'Content-Type: application/json' -d'
{
  "index_patterns": [
    "metrics-results*"
  ],

  "settings": {
    "number_of_shards": 1
  },

  "mappings": {
    "dynamic": "false",

    "dynamic_templates": [
      { "keywords": {
        "match_mapping_type": "string",
        "path_match":   "client.*,target.*",
        "mapping": { "type": "keyword" }
      }}
    ],

    "properties": {
      "@timestamp": {
        "type": "date"
      },

      "build_id": {
        "type": "keyword"
      },

      "action": {
        "type": "keyword"
      },

      "client": {
        "type": "object",
        "properties": {
          "name": {
            "type": "keyword"
          },
          "version": {
            "type": "keyword"
          }
        }
      },

      "target": {
        "type": "object",
        "properties": {
          "name": {
            "type": "keyword"
          },
          "type": {
            "type": "keyword"
          },
          "version": {
            "type": "keyword"
          }
        }
      },

      "duration" : {
        "properties": {
          "min": { "type" : "double", "index": false },
          "max": { "type" : "double", "index": false },
          "avg": { "type" : "double", "index": false }
        }
      },

      "reps_per_sec": {
        "type": "double"
      },

      "ops_per_sec": {
        "type": "double"
      },

      "tags" : { "type" : "keyword" }
    }
  }
}
'

if [[ -n $FORCE ]]; then
  curl -ksS -X PUT "$ELASTICSEARCH_URL/metrics-results?pretty"
  curl -ksS -X POST "$ELASTICSEARCH_URL/_transform/metrics-results/_start?pretty"
fi
