module Jsonify
  module Generate

    class << self

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
        JsonTrue.new
      end

      def false_value
        JsonFalse.new
      end

      def null_value
        JsonNull.new
      end

    end

  end

end