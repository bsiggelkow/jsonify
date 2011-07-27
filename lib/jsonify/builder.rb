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
    #
    # @param sym [String] the key for the pair
    # @param *args [arguments] If a block is passed, the first argument will be iterated over and the subsequent result will be added to a JSON array; otherwise, the arguments set value for the `JsonPair`
    # @param &block a code block the result of which will be used to populate the value for the JSON pair
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
    
    # Stores the key and value into a JSON object
    # @param key the key for the pair
    # @param value the value for the pair
    # @return self to allow for chaining
    def store!(key, value=nil)
      (@stack[@level] ||= JsonObject.new).add(key,value)
      self
    end

    alias_method :[]=, :store!
    
    # Append -- pushes the given object on the end of a JsonArray.
    def <<(val)
      __append(val)
      self
    end

    # Append -- pushes the given variable list objects on to the end of the JsonArray 
    def append!(*args)
      args.each do |arg| 
        __append( arg )
      end
      self
    end

    # Adds a new JsonPair to the builder where the key of the pair is set to the method name
    # (`sym`).
    # When passed a block, the value of the pair is set to the result of that 
    # block; otherwise, the value is set to the argument(s) (`args`).
    #
    # @example Create an object literal
    #     json.person do
    #       json.first_name @person.given_name
    #       json.last_name @person.surname
    #     end
    # 
    # @example compiles to something like ...
    #     "person": {
    #       "first_name": "George",
    #       "last_name": "Burdell"
    #     }
    # 
    # If a block is given and an argument is passed, the argument it is assumed to be an 
    # Array (more specifically, an object that responds to `each`). 
    # The argument is iterated over and each item is yielded to the block.
    # The result of the block becomes an array item of a JsonArray.
    #
    # @example Map an of array of links to an array of JSON objects
    #     json.links(@links) do |link|
    #       {:rel => link.first, :href => link.last}
    #     end
    # 
    # @example compiles to something like ...
    #     "links": [
    #        {
    #          "rel": "self",
    #          "href": "http://example.com/people/123"
    #        },
    #        {
    #          "rel": "school",
    #          "href": "http://gatech.edu"
    #        }
    #     ]
    #
    # @param *args [Array] iterates over the given array yielding each array item to the block; the result of which is added to a JsonArray
    def method_missing(sym, *args, &block)
      
      # When no block given, simply add the symbol and arg as key - value for a JsonPair to current
      return __store( sym, args.length > 1 ? args : args.first ) unless block

      # In a block; create a JSON pair (with no value) and add it to the current object
      pair = Generate.pair_value(sym)
      __store pair

      # Now process the block
      @level += 1

      if args.empty?
        block.call
      else
        args.first.each do |arg|
          __append block.call(arg)
        end
      end

      # Set the value on the pair to the object at the top of the stack
      pair.value = @stack[@level]

      # Pop current off the top of the stack; we are done with it at this point
      @stack.pop

      @level -= 1
    end
    
    private
    
    # BlankSlate requires the __<method> names

    def __store(key,value=nil)
      (@stack[@level] ||= JsonObject.new).add(key,value)
    end  

    def __append(value)
      (@stack[@level] ||= JsonArray.new).add value
    end

  end
end