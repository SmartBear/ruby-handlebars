require_relative 'if_helper'
require_relative 'each_helper'
require_relative 'helper_missing_helper'


module Handlebars
  module Helpers
    def self.register_default_helpers(hbs)
      IfHelper.register(hbs)
      EachHelper.register(hbs)
      HelperMissingHelper.register(hbs)
    end
  end
end
