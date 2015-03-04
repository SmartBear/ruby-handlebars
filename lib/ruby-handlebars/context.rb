module Handlebars
  class Context
    def initialize(data)
      @data = data
    end

    def get(path)
      items = path.split('.')

      current = @data
      until items.empty?
        current = get_attribute(current, items.shift)
      end

      current
    end

    private

    def get_attribute(item, attribute)
      sym_attr = attribute.to_sym
      str_attr = attribute.to_s

      if item.respond_to?('[]')
        if item.has_key?(sym_attr)
          return item[sym_attr]
        elsif item.has_key?(str_attr)
          return item[str_attr]
        end
      end

      p.instance_variable_get("@{attribute}")
    end
  end
end