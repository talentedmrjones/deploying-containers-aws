'use strict'
const express = require('express')
const morgan = require('morgan')
const app = express()
const pkg = require('./package.json')

// use morgan to log all request in the Apache combined format to STDOUT
app.use(morgan('combined'))

// respond to all GET requests
app.get('*', function (req, res) {
  res.set('Server', pkg.name + '/v' + pkg.version)
  res.json({ message: 'MESSAGES service online', version: pkg.version });
})

app.listen(80, function () {
  console.log('service listening on port 80')
})
