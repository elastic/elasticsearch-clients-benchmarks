#!/usr/bin/env bash

if [[ -z $ELASTICSEARCH_URL ]]; then
  echo -e "\033[31;1mERROR:\033[0m Required environment variable [ELASTICSEARCH_URL] not set\033[0m"; exit 1
fi

curl -k -X PUT "$ELASTICSEARCH_URL/_template/metrics-intake?pretty" -H 'Content-Type: application/json' -d'
{
  "index_patterns": [
    "metrics-intake*"
  ],

  "settings": {
    "number_of_shards": 1
  },

  "mappings": {
    "dynamic": "strict",

    "dynamic_templates": [
      { "labels": {
        "match_mapping_type": "string",
        "path_match":   "labels.*",
        "mapping": { "type": "keyword" }
      }}
    ],

    "properties": {
      "@timestamp": {
        "type": "date"
      },

      "benchmark": {
        "properties": {
          "iterations":  { "type": "long", "index": false },
          "repetitions": { "type": "long", "index": false },
          "warmups":     { "type": "long", "index": false }
        }
      },

      "event" : {
        "properties" : {
          "action" : { "type" : "keyword" },
          "duration" : { "type" : "long", "index": false }
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

      "os" : {
        "properties" : {
          "family": { "type" : "keyword" }
        }
      },

      "runtime" : {
        "properties" : {
          "name":    { "type" : "keyword" },
          "version": { "type" : "keyword" }
        }
      },

      "git" : {
        "properties" : {
          "repository": { "type" : "keyword" },
          "branch":     { "type" : "keyword" },
          "commit":     { "type" : "keyword" }
        }
      },

      "tags" : { "type" : "keyword" },
      "labels" : { "type" : "object", "dynamic": true }
    }
  }
}
'
