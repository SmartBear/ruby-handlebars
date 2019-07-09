module Handlebars
  module Helpers
    class EachHelper
      def self.register(hbs)
        hbs.register_helper('each') do |context, items, block, else_block|
          if (items.nil? || items.empty?)
            if else_block
              result = else_block.fn(context)
            end
          else
            context.with_temporary_context(:this => nil, :@index => 0, :@first => false, :@last => false) do
              result = items.each_with_index.map do |item, index|
                context.add_items(:this => item, :@index => index, :@first => (index == 0), :@last => (index == items.length - 1))
                block.fn(context)
              end.join('')
            end
          end
          result
        end
      end
    end
  end
end
