require_relative 'tree'

module Handlebars
  class Helper
    def initialize(hbs, fn)
      @hbs = hbs
      @fn = fn
    end

    def apply(context, arguments = [], block = [])
      arguments = [arguments] unless arguments.is_a? Array
      args = [context] + arguments.map {|arg| arg.eval(context)} + split_block(block || [])

      @fn.call(*args)
    end

    def split_block(block)
      helper_block = Tree::Block.new([])
      inverse_block = Tree::Block.new([])

      receiver = helper_block

      block.each do |item|
        if item.is_a?(Tree::Replacement) && item.is_else?
          receiver = inverse_block
          next
        end

        receiver.add_item(item)
      end

      return helper_block, inverse_block
    end
  end
end