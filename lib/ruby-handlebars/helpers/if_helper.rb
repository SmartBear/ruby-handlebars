require_relative 'default_helper'

module Handlebars
  module Helpers
    class IfHelper < DefaultHelper
      def self.registry_name
        'if'
      end

      def self.apply(context, condition, block, else_block)
        condition = !condition.empty? if condition.respond_to?(:empty?)

        if condition
          block.fn(context)
        elsif else_block
          else_block.fn(context)
        else
          ""
        end
      end
    end
  end
end
