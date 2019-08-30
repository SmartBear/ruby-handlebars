require_relative 'default_helper'

module Handlebars
  module Helpers
    class EachHelper < DefaultHelper
      def self.registry_name
        'each'
      end

      def self.apply(context, items, block, else_block)
        self.apply_as(context, items, :this, block, else_block)
      end

      def self.apply_as(context, items, name, block, else_block)
        if (items.nil? || items.empty?)
          if else_block
            result = else_block.fn(context)
          end
        else
          context.with_temporary_context(name => nil, :@index => 0, :@first => false, :@last => false) do
            result = items.each_with_index.map do |item, index|
              context.add_items(name => item, :@index => index, :@first => (index == 0), :@last => (index == items.length - 1))
              block.fn(context)
            end.join('')
          end
        end
        result
      end
    end
  end
end
