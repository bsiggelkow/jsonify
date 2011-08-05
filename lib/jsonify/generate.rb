module Jsonify
  
  # Provides a set of functions for creating JsonValues from Ruby objects.
  module Generate

    class << self
      
      # Coerces the given value into a JsonValue (or subclass), String, or Number.
      #
      # The coercion rules are based on the type (class) of the value as follows:
      # - +JsonValue+ => no coercion
      # - +String+    => no coercion
      # - +Numeric+   => no coercion
      # - +TrueClass+ => JsonTrue   ( true )
      # - +FalseClass+=> JsonFalse  ( false )
      # - +NilClass+  => JsonNull   ( null )
      # - +Array+     => JsonArray  ( [1,2,3] )
      # - +Hash+      => JsonObject ( <code>{"\a":1,\"b\":2}</code> )
      # - +else+      => #to_s
      # 
      # @param val value to coerce into a JsonValue.
      def value(val)
        case val
          when JsonValue, String, Numeric; val
          when TrueClass;  @json_true  ||= JsonTrue.new
          when FalseClass; @json_false ||= JsonFalse.new
          when NilClass;   @json_null  ||= JsonNull.new
          when Array; array_value val
          when Hash;  object_value val
          else val.to_s
        end
      end
    
      def pair_value(key,val=nil)
        JsonPair.new(key,value(val))
      end
    
      def object_value(hash)
        json_object = JsonObject.new
        hash.each { |key,val| json_object.add( pair_value(key, val) ) }
        json_object
      end
    
      def array_value(vals)
        JsonArray.new(Array(vals).map{ |v| value v })
      end
    
    end

  end

end