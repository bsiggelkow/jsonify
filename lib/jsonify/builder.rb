module Jsonify
  class Builder < BlankSlate

    # Initializes a new builder. The Jsonify::Builder works by keeping a stack of +JsonValue+s.
    #
    # @param [Hash] options the options to create with
    # @option options [boolean] :verify Builder will verify that the compiled JSON string is parseable;  this option does incur a performance penalty and generally should only be used in development
    # @option options [pretty] :pretty Builder will output the JSON string in a prettier format with new lines and indentation; this option does incur a performance penalty and generally should only be used in development
    def initialize(options={})
      @verify = options[:verify].nil? ? false : options[:verify] 
      @pretty = options[:pretty].nil? ? false : options[:pretty] 
      reset!
    end
    
    # Clears the builder data
    def reset!
      @level = 0
      @stack = []
    end

    # Adds a new JsonPair to the builder. Use this method if the pair "key" has spaces or other characters that prohibit creation via method_missing.
    # If a block is given, the result of that block will be set as the value for the JSON pair.
    #
    # @param sym [String] the key for the pair
    # @param *args [arguments] the value(s) used for the value of the pair; +args+ are ignored if a block is passed.
    # @param &block a code block the result of which will be set as the value for the JSON pair
    def tag!(sym, *args, &block)
      method_missing(sym, *args, &block)
    end
    
    # Compiles the JSON objects into a string representation. 
    # If initialized with +:verify => true+, the compiled result will be verified by attempting to re-parse it using +JSON.parse+.
    # If initialized with +:pretty => true+, the compiled result will be parsed and regenerated via +JSON.pretty_generate+.
    # This method can be called without any side effects. You can call +compile!+ at any time, and multiple times if desired.
    #
    # @raise [TypeError] only if +:verify+ is set to true
    # @raise [JSON::ParseError] only if +:verify+ is set to true
    def compile!
      result = (@stack[0] ? @stack[0].evaluate : {}.to_json)
      JSON.parse(result) if @verify
      @pretty ? JSON.pretty_generate(JSON.parse(result)) : result
    end
    
    # Adds the value(s) to the current JSON object in the builder's stack.
    # @param *args values
    def add!(*args)
      __current.add *args
    end
    
    alias_method :<<, :add!

    # Adds a new JsonPair to the builder. 
    # This method will be called if the name does not match an existing method name.
    #
    # @param *args [Array] iterates over the given array yielding each array item to the block; the result of which is added to a JsonArray
    # see tag!
    def method_missing(sym, *args, &block)
      
      # When no block given, simply add the symbol and arg as key - value for a JsonPair to current
      return __current.add( sym, args.length > 1 ? args : args.first ) unless block

      # Create a JSON pair and add it to the current object
      pair = Generate.pair_value(sym) 
      __current.add(pair)

      # Now process the block
      @level += 1

      unless args.empty?
        # Argument was given, iterate over it and add result to a JsonArray
        __set_current JsonArray.new
        args.first.each do |arg|
          __current.add block.call(arg)
        end
      else
        # No argument was given; ordinary JsonObject is expected
        block.call(self)
      end

      # Set the value on the pair to current
      pair.value = __current

      # Pop current off the top of the stack; we are done with it at this point
      @stack.pop

      @level -= 1
    end
    
    # Sets the object at the top of the stack to a new JsonObject, which is yielded to the block.
    def object!
      __set_current JsonObject.new
      yield __current
    end
    
    # Sets the object at the top of the stack to a new JsonArray, which is yielded to the block.
    def array!
      __set_current JsonArray.new
      @level += 1
        yield @stack[@level-1]
      @level -= 1
      __current
    end

    # Maps each element in the given array to a JsonArray. The result of the block becomes an array item of the JsonArray.
    # @param array array of objects to iterate over.
    #
    # @example Map an of array of links to an array of JSON objects
    #    json.links do
    #      json.map!(links) do |link|
    #        {:rel => link.first, :href => link.last}
    #      end
    #    end
    # 
    # @example compiles to something  like ...
    #    "links": [
    #      {
    #        "rel": "self",
    #        "href": "http://example.com/people/123"
    #      },
    #      {
    #        "rel": "school",
    #        "href": "http://gatech.edu"
    #      }
    #    ]
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

    # Current object at the top of the stack. If there is no object there; initializes to a new JsonObject
    # 
    # @return [JsonValue] object at the top of the stack
    def __current
      @stack[@level] ||= JsonObject.new
    end

    # Sets the current object at the top of the stack
    #
    # @param val object to set at the top of the stack
    def __set_current(val)
      @stack[@level] = val
    end
    
  end
end