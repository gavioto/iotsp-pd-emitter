require "socket"

data = "This is test message from Ruby client"
UNIXSocket.open("./tmp/in_literal.sock"){|s|s.write data}

