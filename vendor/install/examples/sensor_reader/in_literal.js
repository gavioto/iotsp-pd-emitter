var net = require('net');
var client = net.connect({path: './tmp/example_in_literal.sock'}, function() {
	client.write('This is test message from node.js client');
	client.end();
});

