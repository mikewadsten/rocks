#!/usr/bin/env node
var restify = require('restify'),
    fs = require('fs'),
    sqlite = require('sqlite3').verbose();

var server = restify.createServer();

var db = new sqlite.Database('data.db');

db.serialize(function() {
    //db.run("DROP TABLE IF EXISTS data");
    columns = ["id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL",
                "ship TEXT", "lz TEXT", "turns INTEGER", "lzpoints INTEGER",
                "algorithm TEXT", "interval INTEGER", "movePlan TEXT",
                "moveHistory TEXT"]
    db.run("CREATE TABLE IF NOT EXISTS data " +
            "(" + columns.join() + ")");
    // Wipe the data out
    //db.run("DELETE FROM data");
    // Reset auto-increment counter
    //db.run("DELETE FROM SQLITE_SEQUENCE WHERE NAME = 'data'");
});

// Parse request bodies before accessing them.
server.use(restify.bodyParser());

function parse_report(body) {
    //console.log("Body: " + body);
    //console.log("Turns: " + (body.turns || -1));
    var stmt = db.prepare("INSERT INTO data " +
            "(ship,lz,turns,lzpoints,algorithm,interval,movePlan,moveHistory) " +
            "VALUES (?,?,?,?,?,?,?,?)");
    args = [body.ship, body.lz, body.turns, body.lzpoints, body.algorithm,
                body.interval, body.movePlan, body.moveHistory];
    newargs = [];
    for (var i = 0; i < args.length; i++)
        newargs.push(JSON.stringify(args[i]));
    //console.log(newargs);
    stmt.run(newargs);
    stmt.finalize();
}

server.get('/stats', function(req, res, next) {
    res.status(200);
    query = "select count(*) as count, min(turns) as min, max(turns) as max, avg(turns) as avg"
    query += " from data"
    return db.get(query, function(err, row) {
        if (err)
            return next(err);

        if (row !== undefined) {
            res.json(row);
        }
        else {
            res.json({"error": "result set is empty"});
        }
        return next();
    });
});

server.get('/nogo', function(req, res, next) {
    fs.readFile('./nogo.html', function(err, content) {
        if (err) {
            res.send(500);
        } else {
            res.contentType = 'html';
            res.status(200);
            res.end(content, 'utf-8');
        }
        return next();
    })
})

server.get(/\/.*/, restify.serveStatic({
    directory: './public',
    default: 'index.html'
}));

server.post('/report', function(req, res, next) {
    //console.log(JSON.stringify(req.body));
    parse_report(req.body);
    res.send(200);
    return next();
});

server.listen(80, function() {
    console.log("%s listening at %s", server.name, server.url);
});
