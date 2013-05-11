#!/usr/bin/env node
var restify = require('restify'),
    fs = require('fs'),
    sqlite = require('sqlite3').verbose();

// Use custom JSON formatter so /stats output is pretty.
// stackoverflow.com/q/10995601
function jsonOut(req, res, body) {
    if (!body) {
        if (res.getHeader('Content-Length') === undefined &&
                res.contentLength === undefined) {
                    res.setHeader('Content-Length', 0);
                }
        return null;
    }

    if (body instanceof Error) {
        // snoop for RestError or HttpError, but don't rely on instanceof
        if ((body.restCode || body.httpCode) && body.body) {
            body = body.body;
        } else {
            body = {
                message: body.message
            };
        }
    }

    if (Buffer.isBuffer(body))
        body = body.toString('base64');

    var data = JSON.stringify(body, null, 2);

    if (res.getHeader('Content-Length') === undefined &&
            res.contentLength === undefined) {
                res.setHeader('Content-Length', Buffer.byteLength(data));
            }

    return data;
}

var server = restify.createServer({formatters: {'application/json': jsonOut}});

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
    for (var i = 0; i < args.length; i++) {
        // Arrays are represented poorly if not stringified
        if (args[i] instanceof Array)
            newargs.push(JSON.stringify(args[i]));
        else
            newargs.push(args[i]);
    }
    //console.log(newargs);
    stmt.run(newargs);
    stmt.finalize();
}

server.get('/stats', function(req, res, next) {
    res.status(200);
    values = ["algorithm", "count(*) as count", "min(turns) as shortest", "max(turns) as longest",
                "avg(turns) as average"]
    query = "select " + (values.join(", ")) + " from data group by algorithm order by algorithm"
    return db.all(query, function(err, rows) {
        if (err)
            return next(err);

        if (rows.length) {
            res.json({stats: rows})
            //res.send(JSON.stringify({stats: rows}))
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
