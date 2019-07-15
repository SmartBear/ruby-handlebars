require_relative 'each_helper'
require_relative 'helper_missing_helper'
require_relative 'if_helper'
require_relative 'unless_helper'

module Handlebars
  module Helpers
    def self.register_default_helpers(hbs)
      EachHelper.register(hbs)
      HelperMissingHelper.register(hbs)
      IfHelper.register(hbs)
      UnlessHelper.register(hbs)
    end
  end
end
