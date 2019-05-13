module Handlebars
  class Context
    def initialize(hbs, data)
      @hbs = hbs
      @data = data
    end

    def get(path)
      items = path.split('.'.freeze)
      if locals.key? items.first.to_sym
        current = locals
      else
        current = @data
      end

      until items.empty?
        current = get_attribute(current, items.shift)
      end

      current
    end

    def escaper
      @hbs.escaper
    end

    def get_helper(name)
      @hbs.get_helper(name)
    end

    def get_as_helper(name)
      @hbs.get_as_helper(name)
    end

    def get_partial(name)
      @hbs.get_partial(name)
    end

    def add_item(key, value)
      locals[key.to_sym] = value
    end

    def add_items(hash)
      hash.map { |k, v| add_item(k, v) }
    end

    def with_temporary_context(args = {})
      saved = args.keys.collect { |key| [key, get(key.to_s)] }.to_h

      add_items(args)
      block_result = yield
      locals.merge!(saved)

      block_result
    end

    private

    def locals
      @locals ||= {}
    end

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
