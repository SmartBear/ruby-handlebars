require_relative 'if_helper'
require_relative 'each_helper'

module Handlebars
  module Helpers
    def self.register_default_helpers(hbs)
      IfHelper.register(hbs)
      EachHelper.register(hbs)
    end
  end
end
