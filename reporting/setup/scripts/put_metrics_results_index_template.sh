#!/usr/bin/env bash

if [[ -z $ELASTICSEARCH_URL ]]; then
  echo -e "\033[31;1mERROR:\033[0m Required environment variable [ELASTICSEARCH_URL] not set\033[0m"; exit 1
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
      { "labels": {
        "match_mapping_type": "string",
        "path_match":   "labels.*,client.*",
        "mapping": { "type": "keyword" }
      }}
    ],

    "properties": {
      "@timestamp": {
        "type": "date"
      },

      "action" : {
        "type" : "keyword"
      },

      "client" : {
        "properties": {
          "name": { "type" : "keyword" }
        }
      },

      "duration" : {
        "properties": {
          "min": { "type" : "double", "index": false },
          "max": { "type" : "double", "index": false },
          "avg": { "type" : "double", "index": false }
        }
      },

      "http" : {
        "properties" : {
          "response" : {
            "properties" : {
              "status_code" : { "type" : "short" }
            }
          }
        }
      },

      "benchmark": {
        "properties": {
          "iterations":  { "type": "long", "index": false },
          "repetitions": { "type": "long", "index": false },
          "warmups":     { "type": "long", "index": false }
        }
      },

      "tags" : { "type" : "keyword" },
      "labels" : { "type" : "object", "dynamic": true }
    }
  }
}
'
