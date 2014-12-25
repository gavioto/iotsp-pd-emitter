# for self(fluentd) log and callback
match("fluent.**") {
  type :record_modifier
  include_tag_key true
  include_time_key true
  localtime true
  tag :fluentlog
}

match('out_fail.fluentlog') {
  type :exec
  command "ruby ./ubin/callback_when_fail"
  format :json
  buffer_type :file
  buffer_path "./var/callback_when_fail_buffer/"
  flush_interval 0.1
}
match('out_success.fluentlog') {
  type :exec
  command "ruby ./ubin/callback_when_success"
  format :json
  buffer_type :file
  buffer_path "./var/callback_when_success_buffer/"
  flush_interval 0.1
}

