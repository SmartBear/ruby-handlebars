module Handlebars
  module Context
    def get(path)
      items = path.split('.'.freeze)

      if @locals.key? items.first.to_sym
        current = @locals
      else
        current = @data
      end
      until items.empty?
        current = get_attribute(current, items.shift)
      end

      current
    end

    def add_item(key, value)
      @locals[key.to_sym] = value
    end

    private

    def get_attribute(item, attribute)
      sym_attr = attribute.to_sym
      str_attr = attribute.to_s

      if item.respond_to?(:[]) && item.respond_to?(:has_key?)
        if item.has_key?(sym_attr)
          return item[sym_attr]
        elsif item.has_key?(str_attr)
          return item[str_attr]
        end
      end

      if item.respond_to?(sym_attr)
        return item.send(sym_attr)
      end
    end
  end
end
