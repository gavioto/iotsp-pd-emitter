# OPTION: callback from emit result watch to self(fluentd) log.
# test:
# $ bin/emitter-logger -l warn -m "AnyError"
#   => execute `./ubin/callback_when_fail`
# $ bin/emitter-logger -l info -m "AnySuccess"
#   => execute `./ubin/callback_when_success`
match("fluent.**") {
  type :record_modifier
  include_tag_key true
  include_time_key true
  localtime true
  tag "fluentlog"
}

match("fluentlog") {
  type :copy
  store {
    type :grep
    regexp1 "tag fluent.warn"
    regexp2 "message AnyError"
    add_tag_suffix "warn"
  }
  store {
    type :grep
    regexp1 "message AnySuccess"
    add_tag_suffix "success"
  }
}

match('fluentlog.warn') {
  type :exec
  command "ruby ./ubin/callback_when_fail"
  format :json
  buffer_type :file
  buffer_path "./var/callback_when_fail_buffer/"
  flush_interval 0.1
}

match('fluentlog.success') {
  type :exec
  command "ruby ./ubin/callback_when_success"
  format :json
  buffer_type :file
  buffer_path "./var/callback_when_success_buffer/"
  flush_interval 0.1
}

