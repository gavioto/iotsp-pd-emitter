# Emitter / demonstration config file.

# REQUIRE: entrypoint(input) from App
source {
  type :unix_unimsg
  path "./tmp/demo_in_unix_unimsg.sock"
  key :data
  tag "test.msg"
}

# REQUIRE: emit to the network/Cloud
match("test.msg.**") {
  type :stdout
}

