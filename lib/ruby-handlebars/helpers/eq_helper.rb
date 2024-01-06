require_relative 'default_helper'

module Handlebars
  module Helpers
    class EqHelper < DefaultHelper
      def self.registry_name
        'eq'
      end

      def self.apply(context, item1, item2, block = nil, else_block = nil)
        if item1 == item2
          block.fn(context)
        elsif else_block
          else_block.fn(context)
        else
          ""
        end
      rescue Exception => err
        ''
      end

    end
  end
end
