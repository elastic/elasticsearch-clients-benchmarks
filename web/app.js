const express = require('express')
const app = express()
const port = 8080

const api = require('./api/index.js')

app.use(express.static('./public'))
app.get('/api', (req, res) => api.handler(req, res))

app.listen(port, () => console.log(`Listening at http://localhost:${port}`))
