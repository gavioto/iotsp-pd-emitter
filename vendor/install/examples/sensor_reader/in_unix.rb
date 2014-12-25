require "msgpack"
require "socket"

record = {"title"=> "Sample", "geo" => [100, 200] }
packed = ["example.data.in_unix", Time.now.to_i, record].to_msgpack # [tag, time, record]
UNIXSocket.open("./tmp/in_unix.sock"){|s|s.write packed}

