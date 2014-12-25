ruby {
  module Fluent::Config::DSL
    class Element < BasicObject
      def load_file(&block)
        path = File.expand_path(block.call)
        Dir.glob(path).each do |f|
          @proxy.eval(File.read(f), f)
        end
      end
    end
  end
}

load_file {
  "./config/conf.d/*.rb"
}

