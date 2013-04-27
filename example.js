var http = require('http'),
    fs = require('fs');

http.createServer(function (req, res) {
    if (req.url.length == 0 || req.url == "/") {
        req.url = "/index.html";
    }
    fs.readFile(__dirname + req.url, function (err, data) {
        if (err) {
            res.writeHead(404);
            res.end(JSON.stringify(err));
            return;
        }
        res.writeHead(200);
        res.end(data);
    })
}).listen(8000, '0.0.0.0');
console.log("Server running on port 8000!");
