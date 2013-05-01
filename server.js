#!/usr/bin/env node
var connect = require('connect'),
    fs = require('fs'),
    http = require('http');

var app = connect()
    .use(connect.logger({format: 'short', stream: fs.createWriteStream("access.log")}))
    .use(connect.static('public'))
    //.use(connect.logger('tiny'))
    .use(function(req, res) {
        res.end('Hello from my little test server!\n')
    });

http.createServer(app).listen(80);
console.log("Started server on port 80.\n");
