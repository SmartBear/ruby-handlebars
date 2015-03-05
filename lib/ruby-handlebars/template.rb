require_relative 'context'

module Handlebars
  class Template
    def initialize(hbs, ast)
      @hbs = hbs
      @ast = ast
    end

    def call(args)
      if args.is_a? Hash
        @hbs.set_context(args)
      end

      @ast.eval(@hbs)
    end
  end
end