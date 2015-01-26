# coding: utf-8
require "socket"

data = "This is test message for Amazon Kinesis"
UNIXSocket.open("./tmp/in_literal_kinesis.sock"){|s|s.write data}

