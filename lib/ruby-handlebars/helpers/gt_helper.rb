require_relative 'default_helper'

module Handlebars
  module Helpers
    class GtHelper < BooleanHelper
      def self.registry_name
        'gt'
      end

      def self.cmp(item1, item2)
        item1 > item2
      end
    end
  end
end