module Handlebars
  module Helpers
    class EqHelper < DefaultHelper
      def self.registry_name
        'eq'
      end

      def self.apply(context, item1, item2, block = nil, else_block = nil)
        item1 == item2 ? 'true' : ''
      rescue Exception => err
        ''
      end
    end
  end
end