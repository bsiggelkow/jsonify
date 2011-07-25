module Jsonify
  
  # Provides a set of functions for creating JsonValues from Ruby objects.
  module Generate

    class << self

      # Coerces the given value into a JsonValue.
      #
      # The coercion rules are based on the type (class) of the value as follows:
      # - +JsonValue+ => no coercion
      # - +String+    => JsonString ( \"foo\" )
      # - +Numeric+   => JsonNumber ( 1 )
      # - +TrueClass+ => JsonTrue   ( true )
      # - +FalseClass+=> JsonFalse  ( false )
      # - +NilClass+  => JsonNull   ( null )
      # - +Array+     => JsonArray  ( [1,2,3] )
      # - +Hash+      => JsonObject ( <code>{"\a":1,\"b\":2}</code> )
      # 
      # @param val value to coerce into a JsonValue.
      def value(val)
        case val
          when JsonValue; val
          when String; string_value val
          when Numeric; number_value val
          when TrueClass; true_value
          when FalseClass; false_value
          when NilClass; null_value
          when Array; array_value val
          when Hash; object_value val
          else string_value val
        end
      end
    
      def pair_value(key,val=nil)
        JsonPair.new(key,value(val))
      end
    
      def string_value(val)
        JsonString.new(val)
      end

      def object_value(hash)
        json_object = JsonObject.new
        hash.each { |key,val| json_object.add( pair_value(key, val) ) }
        json_object
      end
    
      def array_value(vals)
        JsonArray.new(Array(vals).map{ |v| value v })
      end
    
      def number_value(val)
        JsonNumber.new(val)
      end

      def true_value
        @json_true ||= JsonTrue.new # memoize
      end

      def false_value
        @json_false ||= JsonFalse.new # memoize
      end

      def null_value
        @json_null ||= JsonNull.new # memoize
      end

    end

  end

end