require "socket"

data = "This is test message"
UNIXSocket.open("./tmp/in_literal.sock"){|s|s.write data}

