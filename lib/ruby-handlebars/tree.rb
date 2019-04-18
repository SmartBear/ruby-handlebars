module Handlebars
  module Tree
    class TreeItem < Struct
      def eval(context)
        _eval(context)
      end
    end

    class TemplateContent < TreeItem.new(:content)
      def _eval(context)
        return content
      end
    end

    class Replacement < TreeItem.new(:item)
      def _eval(context)
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

    class String < TreeItem.new(:content)
      def _eval(context)
        return content
      end
    end

    class Parameter < TreeItem.new(:name)
      def _eval(context)
        if name.is_a?(Parslet::Slice)
          context.get(name.to_s)
        else
          name._eval(context)
        end
      end
    end

    class Helper < TreeItem.new(:name, :parameters, :block)
      def _eval(context)
        context.get_helper(name.to_s).apply(context, parameters, block)
      end
    end

    class Partial < TreeItem.new(:partial_name)
      def _eval(context)
        context.get_partial(partial_name.to_s).call(context)
      end
    end

    class Block < TreeItem.new(:items)
      def _eval(context)
        items.map {|item| item._eval(context)}.join()
      end
      alias :fn :_eval

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

    rule(
      helper_name: simple(:name),
      parameters: subtree(:parameters)
    ) {
      Tree::Helper.new(name, parameters)
    }

    rule(
      helper_name: simple(:name),
      block_items: subtree(:block_items)
    ) {
      Tree::Helper.new(name, [], block_items)
    }

    rule(
      helper_name: simple(:name),
      parameters: subtree(:parameters),
      block_items: subtree(:block_items)
    ) {
      Tree::Helper.new(name, parameters, block_items)
    }

    rule(partial_name: simple(:partial_name)) {Tree::Partial.new(partial_name)}
    rule(block_items: subtree(:block_items)) {Tree::Block.new(block_items)}
  end
end
