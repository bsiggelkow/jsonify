module Jsonify
  class JsonValue
    attr_accessor :values
    def initialize(values=nil)
      @values = values || []
    end
    
    def evaluate
      wrap( 
        (values.map {|v| v.evaluate}).join(',')
      )
    end
    
    def wrap(joined_values)
      joined_values
    end
    
    def add(jsonValue)
      values << jsonValue
    end

  end
  
  class JsonObject < JsonValue
    def initialize(values=nil)
      @values = values || {}
    end
    def wrap(joined_values)
      "{#{joined_values}}"
    end
    def evaluate
      wrap( 
        (values.values.map {|v| v.evaluate}).join(',')
      )
    end
    def add(json_tuple)
      @values.store(json_tuple.key, json_tuple)
    end
  end

  class JsonArray < JsonValue
    def wrap(joined_values)
      "[#{joined_values}]"
    end
    
    def add(jsonValue)
      values.add(jsonValue)
    end 
  end
  
  class JsonTuple < JsonValue
    attr_accessor :key, :value
    def initialize(key, value)
      @key = key.to_s
      @value = value
    end

    def add(jsonValue)
      value.add(jsonValue)
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