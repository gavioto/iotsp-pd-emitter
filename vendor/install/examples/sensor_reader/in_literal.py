import socket
s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.connect("./tmp/example_in_literal.sock")
s.send("This is test message from Python client")
s.close()

