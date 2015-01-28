desc "start Emitter"
task :start do
  conffile = (ENV['RUN_ENV'].downcase rescue "") == "development" ? "config/fluent_development.rb" : "config/fluent.rb"
  sh "fluentd -c #{conffile} --suppress-repeated-stacktrace"
end

namespace :install do
  desc "Install Demo"
  task :demo do
    mkdir_p "config/conf.d/"
    cp FileList["vendor/install/demo/conf.d/*.rb"], "config/conf.d/"
    mkdir_p "config/gemfile.d/"
    cp FileList["vendor/install/demo/gemfile.d/*.*"], "config/gemfile.d/"
    puts <<-EOT

  ##
  ## Demo install successed.
  ##

  QuickStart:

  At once: `bundle install`
  Start  : `RUN_ENV=development bundle exec rake start`
  #> Run on other console and pay attension to "rake start" console.
  1. `bundle exec ruby -rsocket -e 'UNIXSocket.open("tmp/demo_in_unix_unimsg.sock"){|s|s.write "hello"}'`
  2. `bundle exec bin/emitter-log-injector -l warn -m "AnyError"`
  3. `bundle exec bin/emitter-log-injector -l info -m "AnySuccess"`

    EOT
  end

  desc "Install Examples"
  task :examples do
    mkdir_p "config/conf.d/"
    cp FileList["vendor/install/examples/conf.d/*.*"], "config/conf.d/"
    mkdir_p "examples_sensor_reader"
    cp FileList["vendor/install/examples/sensor_reader/*.*"], "examples_sensor_reader/"
    puts <<-EOT

  ##
  ## Examples install successed.
  ##

  QuickStart:

  At once: `bundle install`
  Start  : `RUN_ENV=development bundle exec rake start`
  #> Run on other console and pay attension to "rake start" console.
  1. `bundle exec ruby examples_sensor_reader/in_literal.rb`
  2. Other examples in README.

    EOT
  end

  desc "Install Amazon Kinesis Demo"
  task :kinesis_demo do
    mkdir_p "config/conf.d/"
    cp FileList["vendor/install/kinesis/conf.d/*.*"], "config/conf.d/"
    mkdir_p "kinesis_demo"
    cp FileList["vendor/install/kinesis/demo/*.*"], "kinesis_demo/"
    puts <<-EOT

  ##
  ## Amazon Kinesis Demo install successed.
  ##

  QuickStart:

  1. Add
    gem "fluent-plugin-kinesis", :github => "awslabs/aws-fluent-plugin-kinesis"
    gem "aws-sdk"
    to Gemfile, and exec `bundle install`
  2. Set your AWS account to config/conf.d/kinesis.json
  3. Your SensorReader rewrite, write to `./tmp/in_literal_kinesis.sock`
     Run your SensorReader! (or kinesis_demo/put.rb)

  Appendix:
  1. kinesis_demo/get.rb is get data example file.

    EOT
  end
end

