module Handlebars
  module Tree
    class TemplateContent < Struct.new(:content)
      def eval(context)
        return content
      end
    end

    class Replacement < Struct.new(:item)
      def eval(context)
        if context.get_helper(item.to_s).nil?
          context.get(item.to_s)
        else
          context.get_helper(item.to_s).apply(context)
        end
      end

      def is_else?
        item.to_s == 'else'
      end
    end

    class String < Struct.new(:content)
      def eval(context)
        return content
      end
    end

    class Parameter < Struct.new(:name)
      def eval(context)
        if name.is_a?(Parslet::Slice)
          context.get(name.to_s)
        else
          name.eval(context)
        end
      end
    end

    class Helper < Struct.new(:name, :parameters, :block)
      def eval(context)
        context.get_helper(name.to_s).apply(context, parameters, block)
      end
    end

    class Partial < Struct.new(:partial_name)
      def eval(context)
        context.get_partial(partial_name.to_s).call(context)
      end
    end

    class Block < Struct.new(:items)
      def eval(context)
        items.map {|item| item.eval(context)}.join()
      end
      alias :fn :eval

      def add_item(i)
        items << i
      end
    end
  end

  class Transform < Parslet::Transform
    rule(template_content: simple(:content)) {Tree::TemplateContent.new(content)}
    rule(replaced_item: simple(:item)) {Tree::Replacement.new(item)}
    rule(str_content: simple(:content)) {Tree::String.new(content)}
    rule(parameter_name: simple(:name)) {Tree::Parameter.new(name)}

    rule(helper_name: simple(:name), parameters: subtree(:parameters)) {Tree::Helper.new(name, parameters)}
    rule(helper_name: simple(:name), parameters: subtree(:parameters), block_items: subtree(:helper_block)) {Tree::Helper.new(name, parameters, helper_block)}

    rule(partial_name: simple(:partial_name)) {Tree::Partial.new(partial_name)}
    rule(block_items: subtree(:block_items)) {Tree::Block.new(block_items)}
  end
end