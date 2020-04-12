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

      "action": {
        "type": "keyword"
      },

      "client": {
        "type": "object"
      },

      "target": {
        "type": "object"
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

      "tags" : { "type" : "keyword" }
    }
  }
}
'
