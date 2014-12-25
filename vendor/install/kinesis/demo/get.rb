# coding: utf-8
require "aws-sdk"
require "json"
require "base64"

$conf = {}
$conf.merge!(JSON.load(open("config/conf.d/kinesis.json"))) if File.exists? "config/conf.d/kinesis.json"
%w(AWS_KINESIS_STREAM_NAME AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION).each do |i|
  $conf.merge!(i => ENV[i]) if ENV[i]
end
AWS.config(:access_key_id => $conf["AWS_ACCESS_KEY_ID"], :secret_access_key => $conf["AWS_SECRET_ACCESS_KEY"])
stream = $conf["AWS_KINESIS_STREAM_NAME"]

client = AWS::Kinesis.new.client
shards = client.describe_stream(stream_name: stream).stream_description.shards
shards.map(&:shard_id).each do |shard_id|
  shard_iterator = client.get_shard_iterator(stream_name: stream, shard_id: shard_id, shard_iterator_type: "TRIM_HORIZON").shard_iterator
  records_info = client.get_records(shard_iterator: shard_iterator, limit: 100)
  records_info.records.each do |record|
    r = Base64.strict_decode64(record.data).force_encoding('utf-8')
    p JSON.parse(r)
  end
end

