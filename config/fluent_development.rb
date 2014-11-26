localconf = ruby {
  pf = {}
  pf.merge!(JSON.load(open("config/pfconf_development.json"))) if File.exists? "config/pfconf_development.json"
  pf.merge!({"pfid" => ENV['IOTSP_EMITTER_PFID']}) if ENV['IOTSP_EMITTER_PFID'] 
  local = {}
  local.merge!(JSON.load(open("config/localconf_development.json"))) if File.exists? "config/localconf_development.json"
  local.merge!({"duid" => ENV['IOTSP_EMITTER_DUID']}) if ENV['IOTSP_EMITTER_DUID'] 
  tag = "%s.u.%s.%s" % [pf["pfid"], pf["wpver"], local["duid"]]
  pf.merge(local.merge({"tag" => tag}))
}

source {
  type :unix
  path File.join("tmp", "in_unix.sock")
}
source {
  type :unix_unimsg
  path File.join("tmp", "in_literal.sock")
  key :data
  tag localconf["tag"]
}

match("#{localconf["pfid"]}.u.**") {
  type :stdout
}

match("fluent.**") {
  type :record_modifier
  include_tag_key true
  include_time_key true
  localtime true
  tag :fluentlog
}
match("fluentlog") {
  type :copy
  store {
    type :grep
    regexp1 "tag fluent.warn"
    regexp2 "message out_http_alt:"
    add_tag_prefix :out_http_alt_fail
  }
  store {
    type :grep
    regexp1 "tag fluent.info"
    regexp2 "message out_http_alt: Send success"
    add_tag_prefix :out_http_alt_success
  }
}
match('out_http_alt_fail.fluentlog') {
  type :exec
  command "ruby ./ubin/callback_when_fail"
  format :json
  buffer_type :file
  buffer_path File.join("var", "callback_when_fail_buffer")
  flush_interval 0.1
}
match('out_http_alt_success.fluentlog') {
  type :exec
  command "ruby ./ubin/callback_when_success"
  format :json
  buffer_type :file
  buffer_path File.join(".", "var", "callback_when_success_buffer")
  flush_interval 0.1
}

match("__for_plugin_load__") {
  type :http_alt
  endpoint_url localconf["endpoint"]["http"]
}
match("_http_error_raise.*") {
  type :_http_error_raise
  flush_interval 0.2
  # MUST: buffer parameters same to out_http_alt.
}

