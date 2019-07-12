module Handlebars
  module Helpers
    class DefaultHelper
      def self.register(hbs)
        hbs.register_helper(self.registry_name) do |context, parameters, block, else_block|
          self.apply(context, parameters, block, else_block)
        end
      end

      # Should be implemented by sub-classes
      # def self.registry_name
      #   'myHelperName'
      # end

      # def self.apply(context, parameters, block, else_block)
      #   # Do things and stuff
      # end
    end
  end
end
