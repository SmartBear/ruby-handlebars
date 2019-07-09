module Handlebars
  module Helpers
    class IfHelper
      def self.register(hbs)
        hbs.register_helper('if') do |context, condition, block, else_block|
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
end
