var app = require('http').createServer(handler),
    io = require('socket.io').listen(app);

app.listen(8001);

function handler(req, res) {
    res.writeHead(200);
    res.write('<html>\n<head>\n<title>Socket testing...</title>\n</head>\n');
    res.write('<body><h1>Hello world!</h1>\n');
    res.write('<script src="/socket.io/socket.io.js"></script>\n');
    res.write('<script>\n');
    res.write('var socket = io.connect("http://vm1.mikewadsten.com:8001");\n');
    res.write('socket.emit("data", {thisismy: "ultra cool data right here"});\n');
    res.write('</script>\n');
    res.write('</body>\n</html>');
    res.end();
}

io.sockets.on('connection', function (socket) {
    socket.on("data", function (data) {
        console.log(data);
    });
});
