#!/usr/bin/env node
var connect = require('connect'),
    http = require('http');

var app = connect()
    .use(connect.static('public'))
    .use(function(req, res) {
        res.end('Hello from my little test server!\n')
    });

http.createServer(app).listen(8000);
console.log("Started server on port 8000.\n");
