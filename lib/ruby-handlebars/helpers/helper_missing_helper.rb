module Handlebars
  class UnknownHelper < StandardError
  end

  module Helpers
    class HelperMissingHelper
      def self.register(hbs)
        hbs.register_helper('helperMissing') do |context, name|
          raise(::Handlebars::UnknownHelper, "Helper \"#{name}\" does not exist" )
        end
      end
    end
  end
end
