module Jsonify
  class Builder < BlankSlate

    def initialize(options={})
      @verify = options[:verify].nil? ? false : options[:verify] 
      @pretty = options[:pretty].nil? ? false : options[:pretty] 
      reset!
    end
    
    def reset!
      @level = 0
      @stack = []
    end

    # Builder-style methods
    def tag!(sym, *args, &block)
      method_missing(sym, *args, &block)
    end
    
    def compile!
      result = (@stack[0] ? @stack[0].evaluate : {}.to_json)
      JSON.parse(result) if @verify
      @pretty ? JSON.pretty_generate(JSON.parse(result)) : result
    end
    
    def add!(*args)
      __current.add *args
    end
    
    alias_method :<<, :add!
    
    def method_missing(sym, *args, &block)
      if block        
        pair = Generate.pair_value(sym)
        __current.add(pair)
        @level += 1
          block.call(self)
          pair.value = __current
        @level -= 1
      else
        if sym && args && args.length > 0
          __current.add( sym, args.length > 1 ? args : args.first )
        end
        __current
      end
    end
    
    def object!
      __set_current JsonObject.new
      yield __current
    end
    
    def array!
      __set_current JsonArray.new
      @level += 1
        yield @stack[@level-1]
      @level -= 1
      __current
    end

    def map!(array)
      __set_current JsonArray.new
      array.each do |item|
        __current << (yield item)
      end
      __current
    end
    
    alias_method :collect!, :map!
    
    private
    
    # Inheriting from BlankSlate requires these funky (aka non-idiomatic) method names

    def __current
      @stack[@level] ||= JsonObject.new
    end

    def __set_current(val)
      @stack[@level] = val
    end
    
  end
end