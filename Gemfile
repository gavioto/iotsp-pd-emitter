source "https://rubygems.org"
gem "rake"
gem "fluentd"

group :development do
  gem "pry-debugger"
end

# http://madebynathan.com/2010/10/19/how-to-use-bundler-with-plugins-extensions/
Dir.glob(File.join(File.dirname(__FILE__), 'config', 'gemfile.d', '*.gemfile')) do |gemfile|
    eval(IO.read(gemfile), binding)
end

