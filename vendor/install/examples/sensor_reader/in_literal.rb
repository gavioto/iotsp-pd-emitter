require "socket"
data = "This is test message from Ruby client"
UNIXSocket.open("./tmp/example_in_literal.sock"){|s|s.write data}

