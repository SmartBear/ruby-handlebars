require_relative 'ruby-handlebars/parser'
require_relative 'ruby-handlebars/tree'
require_relative 'ruby-handlebars/template'
require_relative 'ruby-handlebars/helper'

module Handlebars
  class Handlebars
    include Context

    def initialize
      @helpers = {}
      @partials = {}
      @locals = {}
      register_default_helpers
    end

    def compile(template)
      Template.new(self, template_to_ast(template))
    end

    def register_helper(name, &fn)
      @helpers[name.to_s] = Helper.new(self, fn)
    end

    def get_helper(name)
      @helpers[name.to_s]
    end

    def register_partial(name, content)
      @partials[name.to_s] = Template.new(self, template_to_ast(content))
    end

    def get_partial(name)
      @partials[name.to_s]
    end

    def set_context(ctx)
      @data = ctx
    end

    private

    PARSER = Parser.new
    TRANSFORM = Transform.new

    def template_to_ast(content)
      TRANSFORM.apply(PARSER.parse(content))
    end

    def register_default_helpers
      register_if_helper
      register_each_helper
    end

    def register_if_helper
      register_helper('if') do |context, condition, block, else_block|
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

    def register_each_helper
      register_helper('each') do |context, items, block, else_block|
        current_this = context.get('this')

        if (items.nil? || items.empty?)
          if else_block
            result = else_block.fn(context)
          end
        else
          result = items.map do |item|
            context.add_item(:this, item)
            block.fn(context)
          end.join('')
        end

        context.add_item(:this, current_this)
        result
      end
    end
  end
end
