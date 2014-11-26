desc "Bootup fluentd"
task :boot do
  conffile = (ENV['RUN_ENV'].downcase rescue "") == "development" ? "config/fluent_development.rb" : "config/fluent.rb"
  sh "fluentd -c #{conffile} --suppress-repeated-stacktrace"
end

desc "Install"
task :install do
  cp File.join("config", "pfconf.json.sample"), File.join("config", "pfconf.json")
  cp File.join("config", "pfconf.json.sample"), File.join("config", "pfconf_development.json")
  cp File.join("config", "localconf.json.sample"), File.join("config", "localconf.json")
  cp File.join("config", "localconf.json.sample"), File.join("config", "localconf_development.json")
end

namespace :raise_error do
  cmd = "echo '{\"data\":1}' | fluent-cat -u -s tmp/in_unix.sock _http_error_raise"
  namespace :network do
    %w(refused timeout socketerror).each {|i|
      desc "raise Network error / #{i}"
      task i do
        verbose(false) { sh "#{cmd}.#{i}" }
      end
    }
  end

  namespace :http do
    %w(200 403 404 500).each {|i|
      desc "raise HTTP #{i}"
      task i do
        verbose(false) { sh "#{cmd}.#{i}" }
      end
    }
  end
end

