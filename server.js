#!/usr/bin/env node
var restify = require('restify');

var server = restify.createServer();

// Parse request bodies before accessing them.
server.use(restify.bodyParser());

function parse_report(body) {
    console.log("Body: " + body);
    console.log("Turns: " + (body.turns || -1));
}

server.get(/\/.*/, restify.serveStatic({
    directory: './public',
    default: 'index.html'
}));

server.post('/report', function(req, res, next) {
    //console.log(req.body);
    parse_report(req.body);
    res.send(200);
    return next();
});

server.listen(8000, function() {
    console.log("%s listening at %s", server.name, server.url);
});
