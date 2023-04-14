require_relative 'context'

module Handlebars
  class Template
    def initialize(hbs, ast, **options)
      @hbs = hbs
      @ast = ast
      @options = options || {}
    end

    def call(args = nil)
      ctx = Context.new(@hbs, args, **@options)

      @ast.eval(ctx)
    end

    def call_with_context(ctx)
      @ast.eval(ctx)
    end
  end
end
