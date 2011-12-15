module Jsonify
  class Builder < BlankSlate
    
    class << self

      # Compiles the given block into a JSON string without having to instantiate a Builder.
      #
      # @option options [boolean] :verify Builder will verify that the compiled JSON string is parseable;  this option does incur a performance penalty and generally should only be used in development
      # @option options [symbol] :format Format for the resultant JSON string; 
      #                          `:pretty`, the JSON string will be output in a prettier format with new lines and indentation; this option does incur a performance penalty and generally should only be used in development
      #                          `:plain`,  no formatting (compact one-line JSON -- best for production)
      # 
      def compile( options={} )
        builder = self.new options
        yield builder
        builder.compile!
      end

      # Compiles the given block into a pretty JSON string without having to instantiate a Builder.
      def pretty(&block)
        compile( :format => :pretty, &block )
      end

      # Compiles the given block into a plain (e.g. no newlines and whitespace) JSON string without having to instantiate a Builder.
      def plain(&block)
        compile( :format => :plain, &block )
      end

    end

    # Initializes a new builder. The Jsonify::Builder works by keeping a stack of +JsonValue+s.
    #
    # @param [Hash] options the options to create with
    # @option options [boolean] :verify Builder will verify that the compiled JSON string is parseable;  this option does incur a performance penalty and generally should only be used in development
    # @option options [symbol] :format Format for the resultant JSON string; 
    #                          `:pretty`, the JSON string will be output in a prettier format with new lines and indentation; this option does incur a performance penalty and generally should only be used in development
    #                          `:plain`,  no formatting (compact one-line JSON -- best for production)
    def initialize(options={})
      @verify = options[:verify].nil? ? false : options[:verify] 
      @pretty = options[:format].to_s == 'pretty' ? true : false 
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
    def tag!(sym, args=nil, &block)
      method_missing(sym, *args, &block)
    end
    
    # Compiles the JSON objects into a string representation. 
    # If initialized with +:verify => true+, the compiled result will be verified by attempting to re-parse it using +MultiJson.decode+.
    # If initialized with +:format => :pretty+, the compiled result will be parsed and encoded via +MultiJson.encode(<json>, :pretty => true)+
    # This method can be called without any side effects. You can call +compile!+ at any time, and multiple times if desired.
    #
    # @raise [TypeError] only if +:verify+ is set to true
    # @raise [JSON::ParseError] only if +:verify+ is set to true
    def compile!
      result = (@stack[0] || {}).encode_as_json
      MultiJson.decode(result) if @verify
      result = MultiJson.encode(MultiJson.decode(result), :pretty => true) if @pretty
      result
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
      __array
      @stack[@level].add val
      self
    end

    # Append -- pushes the given variable list objects on to the end of the JsonArray 
    def append!(*args)
      __array
      args.each do |arg| 
        @stack[@level].add arg
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
    # The result of the block becomes an array item of the JsonArray.
    #
    # @example Map an of array of links to an array of JSON objects
    #     json.links(@links) do |link|
    #       json.rel link.first
    #       json.href link.last
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
    def method_missing(sym, args=nil, &block)
      
      # When no block given, simply add the symbol and arg as key - value for a JsonPair to current
      return __store( sym, args ) unless block

      # In a block; create a JSON pair (with no value) and add it to the current object
      pair = Generate.pair_value(sym)
      __store pair

      # Now process the block
      @level += 1

      if args.nil?
        block.call
      else
        __array
        args.each do |arg|
          @level += 1
          block.call(arg)
          @level -= 1
          
          value = @stack.pop

          # If the object created was an array with a single value
          # assume that just the value should be added
          if (JsonArray === value && value.values.length <= 1)
            value = value.values.first
          end

          @stack[@level].add value
        end
      end

      # Set the value on the pair to the object at the top of the stack
      pair.value = @stack[@level]

      # Pop current off the top of the stack; we are done with it at this point
      @stack.pop

      @level -= 1
    end
    
    # Ingest a full JSON representation (either an oject or array)
    # into the builder. The value is parsed, objectified, and added to the
    # current value at the top of the stack.
    #
    # @param [String] json_string a full JSON string (e.g. from a rendered partial)
    def ingest!(json_string)
      return if json_string.empty?
      res = Jsonify::Generate.value(MultiJson.decode(json_string))
      current = @stack[@level]
      if current.nil?
        @stack[@level] = res
      elsif JsonObject === current
        if JsonObject === res
          @stack[@level].merge res
        else 
          raise ArgumentError.new("Cannot add JSON array to JSON Object")
        end
      else # current is JsonArray
        @stack[@level].add res
      end
    end

    private
    
    # BlankSlate requires the __<method> names
    
    def __store(key,value=nil)
      pair = (JsonPair === key ? key : JsonPair.new(key, value))
      (@stack[@level] ||= JsonObject.new).add(pair)
    end  

    def __array
      @stack[@level] ||= JsonArray.new
    end

  end
end
