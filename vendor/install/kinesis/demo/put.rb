# coding: utf-8
require "socket"
data = "This is test message for Amazon Kinesis"
UNIXSocket.open("./tmp/kinesis_in_literal.sock"){|s|s.write data}

