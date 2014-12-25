var net = require('net');
var client = net.connect({path: './tmp/in_literal.sock'}, function() {
	client.write('This is test message');
	client.end();
});

