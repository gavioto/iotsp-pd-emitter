# config load
kinesis = ruby {
  c = {}
  # from file
  c.merge!(JSON.load(open("config/conf.d/kinesis.json"))) if File.exists? "config/conf.d/kinesis.json"
  # from ENV and override
  %w(AWS_KINESIS_STREAM_NAME AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION).each do |i|
    c.merge!(i => ENV[i]) if ENV[i]
  end
  c
}

# input from sensorPGM
source {
  type :unix_unimsg
  path "./tmp/kinesis_in_literal.sock"
  key :data
  tag "to.kinesis.test"
}

# emit to cloud
match("to.kinesis.**") {
  type :copy
  store {
    type :kinesis
    stream_name kinesis["AWS_KINESIS_STREAM_NAME"]
    aws_key_id kinesis["AWS_ACCESS_KEY_ID"]
    aws_sec_key kinesis["AWS_SECRET_ACCESS_KEY"]
    region kinesis["AWS_REGION"]
    random_partition_key true
  }
  store {
    type :stdout
  }
}

