#!/usr/bin/env bash

if [[ -z $ELASTICSEARCH_URL ]]; then
  echo -e "\033[31;1mERROR:\033[0m Required environment variable [ELASTICSEARCH_URL] not set\033[0m"; exit 1
fi

if [[ -n $FORCE ]]; then
  curl -ksS -X DELETE "$ELASTICSEARCH_URL/_transform/metrics-results?force=true&pretty"
  curl -ksS -X DELETE "$ELASTICSEARCH_URL/metrics-results?pretty"
fi

curl -ksS -X PUT "$ELASTICSEARCH_URL/_transform/metrics-results?pretty" -H 'Content-Type: application/json' -d @-<<EOF
{
  "source": {
    "index": [
      "metrics-intake*"
    ]
  },
  "dest": {
    "index": "metrics-results"
  },
  "frequency": "1m",
  "sync": {
    "time": {
      "field": "@timestamp",
      "delay": "60s"
    }
  },
  "pivot": {
    "group_by": {
      "@timestamp": {
        "date_histogram": {
          "field": "@timestamp",
          "fixed_interval": "15m"
        }
      },

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

      "category": {
        "terms": {
          "field": "benchmark.category"
        }
      },

      "environment": {
        "terms": {
          "field": "benchmark.environment"
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

      "target.type": {
        "terms": {
          "field": "benchmark.target.service.type"
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
      },
      "reps_per_sec": {
        "scripted_metric": {
          "init_script": "state.total_duration = 0.0; state.total_repetitions = 0.0",
          "map_script": "state.total_duration += params['_source']['event']['duration']; state.total_repetitions += 1",
           "combine_script" : "return state.total_repetitions / (state.total_duration / 1e9)",
           "reduce_script" : "double reps_per_sec = 0; for (s in states) { reps_per_sec += s } return reps_per_sec"
        }
      },
      "ops_per_sec": {
          "scripted_metric": {
            "init_script": "state.total_duration = 0.0; state.total_operations = 0.0",
            "map_script": "state.total_duration += params['_source']['event']['duration']; int ops = 0; if (params['_source']['benchmark']['operations'] == null) { ops = 1 } else { ops = params['_source']['benchmark']['operations'] } state.total_operations += ops",
             "combine_script" : "return state.total_operations / (state.total_duration / 1e9)",
             "reduce_script" : "double ops_per_sec = 0; for (s in states) { ops_per_sec += s } return ops_per_sec"
          }
        }
      }
    }
  }
}
EOF

curl -ksS -X PUT "$ELASTICSEARCH_URL/metrics-results?pretty"
curl -ksS -X POST "$ELASTICSEARCH_URL/_transform/metrics-results/_start?pretty"
