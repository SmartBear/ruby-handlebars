require_relative 'default_helper'

module Handlebars
  module Helpers
    class UnlessHelper < DefaultHelper
      def self.registry_name
        'unless'
      end

      def self.apply(context, condition, block, else_block)
        condition = !condition.empty? if condition.respond_to?(:empty?)

        unless condition
          block.fn(context)
        else
          else_block ? else_block.fn(context) : ""
        end
      end
    end
  end
end
