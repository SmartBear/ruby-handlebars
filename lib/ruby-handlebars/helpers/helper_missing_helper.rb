require_relative 'default_helper'

module Handlebars
  class UnknownHelper < StandardError
  end

  module Helpers
    class HelperMissingHelper < DefaultHelper
      def self.registry_name
        'helperMissing'
      end

      def self.apply(context, name, block, else_block)
        raise(::Handlebars::UnknownHelper, "Helper \"#{name}\" does not exist" )
      end
    end
  end
end
