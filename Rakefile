desc "start Emitter"
task :start do
  conffile = (ENV['RUN_ENV'].downcase rescue "") == "development" ? "config/fluent_development.rb" : "config/fluent.rb"
  sh "fluentd -c #{conffile} --suppress-repeated-stacktrace"
end

