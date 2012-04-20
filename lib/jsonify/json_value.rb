class Object
  def encode_as_json
    MultiJson.dump self
  end
end

module Jsonify
  class JsonValue
    attr_accessor :values

    def initialize(values=nil)
      @values = values || []
    end
    
    def encode_as_json
      wrap values.map {|v| v.encode_as_json}.join(',')
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
    
  end
  
  class JsonPair < JsonValue
    attr_accessor :key, :value
    def initialize(key, value=nil)
      @key = key.to_s
      @value = Generate.value(value)
    end
    def encode_as_json
      %Q{#{key.encode_as_json}:#{value.encode_as_json}}
    end
  end

  class JsonTrue < JsonValue
    def encode_as_json
      'true'
    end
  end
  
  class JsonFalse < JsonValue
    def encode_as_json
      'false'
    end
  end
  
  class JsonNull < JsonValue
    def encode_as_json
      'null'
    end
  end
  
end