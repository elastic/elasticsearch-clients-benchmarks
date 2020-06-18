var https = require('https')

const elasticsearchURL = process.env.ELASTICSEARCH_URL + '/metrics-results/_search'

const requestBody = `
{
  "size": 0,
  "query": {
    "bool": {
      "must": [
        { "range": { "@timestamp": { "gte": "now-90d/d" }}},
        { "term": { "target.type": { "value": "elasticsearch" }}}
      ]
    }
  },
  "aggregations" : {
    "timeline": {
      "date_histogram": {
        "field": "@timestamp",
        "calendar_interval": "day"
      },
      "aggregations": {
        "action": {
          "terms": {
            "field": "action",
            "size": 50
          },
          "aggregations": {
            "client_name": {
              "terms": {
                "field": "client.name",
                "size": 25
              },
              "aggregations": {
                "ops_per_sec": {
                  "percentiles": {
                    "field": "ops_per_sec",
                    "percents": [50, 95, 99]
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}`

const requestOptions = {
  method: 'POST',
  headers: {
    Accept: 'application/json',
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(requestBody)
  }
}

exports.handler = function (_, out) {
  out.append('Content-Type', 'application/json')
  out.append('Access-Control-Allow-Origin', '*')
  const req = https.request(
    elasticsearchURL,
    requestOptions,
    (res) => {
      let body = ''
      res.on('data', chunk => { body += chunk })
      res.on('end', () => {
        if (res.statusCode > 200) {
          console.error(res.statusCode, body)
        }
        out.status(res.statusCode).send(body).end()
      })
    }
  )

  req.on('error', (e) => {
    console.log(e)
    out.status(500).send(`{"error": "${e.toString()}"}`).end()
  })

  req.write(requestBody)
  req.end()
}
