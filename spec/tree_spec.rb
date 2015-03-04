require 'pry'

require_relative 'spec_helper'
require_relative '../lib/ruby-handlebars/parser'
require_relative '../lib/ruby-handlebars/tree'


describe Handlebars::Transform do
  let(:parser) {Handlebars::Parser.new}
  let(:transform) {Handlebars::Transform.new}

  def get_ast(content)
    transform.apply(parser.parse(content))
  end

end