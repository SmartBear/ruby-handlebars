module Handlebars
  module Escapers
    class DummyEscaper
      def self.escape(value)
        value
      end
    end
  end
end