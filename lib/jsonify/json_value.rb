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

    def add(json_pair)
      @values.store(json_pair.key, json_pair)
    end
  end

  class JsonArray < JsonValue
    
    alias_method :<<, :add
    
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
    
  end
  
  class JsonPair < JsonValue
    attr_accessor :key, :value
    def initialize(key, value=nil)
      @key = key.to_s
      @value = value || JsonNull.new
    end
    def evaluate
      %Q{\"#{key}\":#{value.evaluate}}
    end
  end
  
  class JsonString < JsonValue
    attr_accessor :value
    def initialize(value)
      @value = value.to_s
    end
    def evaluate
      "\"#{value}\""
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