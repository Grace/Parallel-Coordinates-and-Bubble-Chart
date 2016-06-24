/*
 * server.js
 * just creates a simple node server that
 * can serve static files.
 *
 * NOTE: this server is not for use in production, filled
 * with security holes. Pretty much the simplest implementation
 * possible.
 *
 * da
 *
 */
var http = require('http'),
		fs = require('fs'),
		csv = require('csv'),
		port = 3000;


http.createServer(function (req, res) {

	fs.readFile(__dirname + req.url, function (err,data) {
		if (err) {
			res.writeHead(404);
			res.write("Sorry, there was an error\n");
			res.write("If it says 'ENOENT', that means you typed in the file path wrong.\n");
			res.end(JSON.stringify(err));
			return;
		}
		res.writeHead(200);
		res.end(data);
	});

}).listen(port);


