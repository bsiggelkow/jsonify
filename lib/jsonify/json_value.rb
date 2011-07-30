module Jsonify
  class JsonValue
    attr_accessor :values

    def initialize(values=nil)
      @values = values || []
    end
    
    def evaluate
      wrap values.map {|v| v.evaluate}.join(',')
    end
    
    def add(jsonValue)
      values << Generate.value(jsonValue)
    end

  end
  
  class JsonObject < JsonValue
    def initialize(values=nil)
      @values = values || {}
    end

    def wrap(joined_values)
      "{#{joined_values}}"
    end

    def values
      @values.values
    end

    def add(key, val=nil)
      pair = ( JsonPair === key ? key : JsonPair.new(key, val) )
      @values.store(pair.key, pair)
    end
    
    def merge(json_object)
      json_object.values.each do |pair|
        @values.store(pair.key, pair)
      end
    end

    alias_method :<<, :add
    alias_method :add!, :add # for consistency with the Builder api

  end

  class JsonArray < JsonValue
    
    def wrap(joined_values)
      "[#{joined_values}]"
    end
    
    def add(value)
      if JsonPair === value # wrap JsonPair in a JsonObject
        object = JsonObject.new
        object.add value
        value = object
      end
      super(value)
    end

    alias_method :<<, :add
    alias_method :add!, :add # for consistency with the Builder api
    
  end
  
  class JsonPair < JsonValue
    attr_accessor :key, :value
    def initialize(key, value=nil)
      @key = key.to_s
      @value = Generate.value(value)
    end
    def evaluate
      %Q{#{key.to_json}:#{value.evaluate}}
    end
  end
  
  class JsonString < JsonValue
    attr_accessor :value
    def initialize(value)
      @value = value.to_s
    end
    def evaluate
      value.to_json
    end
  end
  
  class JsonNumber < JsonValue
    attr_accessor :value
    def initialize(value)
      @value = value
    end
    def evaluate
      value
    end
  end

  class JsonTrue < JsonValue
    def evaluate
      'true'
    end
  end
  
  class JsonFalse < JsonValue
    def evaluate
      'false'
    end
  end
  
  class JsonNull < JsonValue
    def evaluate
      'null'
    end
  end
  
end