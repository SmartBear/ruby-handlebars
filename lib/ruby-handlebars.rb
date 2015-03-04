require_relative 'ruby-handlebars/parser'
require_relative 'ruby-handlebars/tree'
require_relative 'ruby-handlebars/template'
require_relative 'ruby-handlebars/helper'

module Handlebars
  class Handlebars
    def initialize
      @helpers = {}
      @partials = {}
    end

    def compile(template)
      Template.new(self, template_to_ast(template))
    end

    def register_helper(name, &fn)
      @helpers[name] = Helper.new(self, fn)
    end

    def get_helper(name)
      @helpers[name]
    end

    def register_partial(name, content)
      @partials[name] = Template.new(self, template_to_ast(content))
    end

    def get_partial(name)
      @partials[name]
    end

    def set_context(ctx)
      @ctx = Context.new(ctx)
    end

    def get(path)
      @ctx.get(path)
    end

    private
    def template_to_ast(content)
      Transform.new.apply(Parser.new.parse(content))
    end
  end
end