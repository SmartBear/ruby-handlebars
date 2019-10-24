module Handlebars
  module Helpers
    class DefaultHelper
      def self.register(hbs)
        hbs.register_helper(self.registry_name) do |context, parameters, block, else_block|
          self.apply(context, parameters, block, else_block)
        end if self.respond_to?(:apply)

        hbs.register_as_helper(self.registry_name) do |context, parameters, as_names, block, else_block|
          self.apply_as(context, parameters, as_names, block, else_block)
        end if self.respond_to?(:apply_as)
      end

      # Should be implemented by sub-classes
      # def self.registry_name
      #   'myHelperName'
      # end

      # def self.apply(context, parameters, block, else_block)
      #   # Do things and stuff
      # end

      # def self.apply_as(context, parameters, as_names, block, else_block)
      #   # Do things and stuffa, but with 'as |param| notation'
      # end
    end

    class BooleanHelper < DefaultHelper
      # Helper that simply return "true" or ""

      def self.apply(context, item1, item2, block = nil, else_block = nil)
        self.cmp(item1, item2) ? 'true' : ''
      rescue Exception => err
        ''
      end

      # To be implemented by sub-classes
      # def self.cmp(item1, item2)
      #   do a boolean comparison on item1 and item2
      # end
    end
  end
end
