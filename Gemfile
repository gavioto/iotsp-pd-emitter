source "https://rubygems.org"
gem "rake"
gem "fluentd", "~> 0.10.0"
gem "fluent-plugin-in_unix_unimsg", :github => "ma2shita/fluent-plugin-in_unix_unimsg"
gem "fluent-plugin-grep"
gem "fluent-plugin-record-modifier", :github => "ma2shita/fluent-plugin-record-modifier", :branch => "include_set_time_key_mixin"

group :development do
  gem "pry-debugger"
  gem "pry-stack_explorer"
end

# http://madebynathan.com/2010/10/19/how-to-use-bundler-with-plugins-extensions/
Dir.glob(File.join(File.dirname(__FILE__), 'config', 'gemfile.d', '*.gemfile')) do |gemfile|
    eval(IO.read(gemfile), binding)
end
