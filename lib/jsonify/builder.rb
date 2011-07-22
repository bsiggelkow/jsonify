module Jsonify
  class Builder < BlankSlate

    def initialize
      @stack = []
      @level = 0
    end
    
    # Builder-style methods
    def tag!(sym, *args, &block)
      method_missing(sym, *args, &block)
    end
    
    def compile!
      @stack[0].evaluate if @stack[0]
    end
    
    def add!(value)
      __current.add Generate.value(value)
    end
    
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
          __current.add Generate.pair_value(sym, args.length > 1 ? args : args.first)
        end
      end
    end
    
    def object!
      __set_current JsonObject.new
      yield __current
    end
    
    def array!
      __set_current JsonArray.new
      yield __current
    end
    
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