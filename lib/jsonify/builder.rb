module Jsonify
  class Builder < BlankSlate

    attr_accessor :stack

    def initialize
      @stack = [JsonObject.new]
      @level = 0
    end
    
    def current
      @current ||= JsonObject.new
    end
    
    def current=(val)
      @current = val
    end
    
    def build!(value)
      case value
        when JsonValue; value
        when String; string! value
        when Numeric; number! value
        when TrueClass; true!
        when FalseClass; false!
        when NilClass; null!
        when Array; array! value
        when Hash; object! value
        else string! value
      end
    end
    
    def tuple!(key,value)
      JsonTuple.new(key,build!(value))
    end
    
    def string!(value)
      JsonString.new(value)
    end
    def object!(hash)
      json_object = JsonObject.new
      hash.each { |key,val| json_object.add( tuple!(key, val) ) }
      json_object
    end
    
    def array!(values)
      JsonArray.new(Array(values).map{ |v| build! v })
    end
    
    def number!(value)
      JsonNumber.new(value)
    end
    def true!
      JsonTrue.new
    end
    def false!
      JsonFalse.new
    end
    def null!
      JsonNull.new
    end

    # Builder-style methods
    def tag!(sym, *args, &block)
      method_missing(sym, *args, &block)
    end
    
    def compile!
      @stack[0].evaluate if @stack[0]
    end
    
    def method_missing(sym, *args, &block)
      if block
        @stack[@level].add(tuple!(sym, json_object = JsonObject.new))
        @stack.push json_object
        @level += 1
        block.call(self)
        @level -= 1
      else
        if sym && args && args.length > 0
          @stack[@level].add tuple!(sym, args.length > 1 ? args : args.first)
        end
      end
    end
    
  end
end