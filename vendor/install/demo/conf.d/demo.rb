# Emitter / demonstration config file.

# REQUIRE: entrypoint(input) from App
source {
  type :unix_unimsg
  path "./tmp/in_unix_unimsg.sock"
  key :data
  tag "test.msg"
}

# REQUIRE: emit to the network/Cloud
match("test.msg.**") {
  type :stdout
}

# OPTION: callback from emit result
# e.g.) $ bin/emitter-logger -l warn -m "AnyError"
# => execute `./ubin/callback_when_fail` by `config/conf.d/callback.rb`
match("fluentlog") {
  type :grep
  regexp1 "tag fluent.warn"
  regexp2 "message AnyError"
  add_tag_prefix :out_fail
}

