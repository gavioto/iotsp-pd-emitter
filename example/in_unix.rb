require "msgpack"
require "socket"

record = {"title"=> "Sample", "geo" => [100, 200] }
packed = ["p0001.u.10021.y", Time.now.to_i, record].to_msgpack # [tag, time, record]
UNIXSocket.open("./tmp/in_unix.sock"){|s|s.write packed}

