require 'spec_helper'

describe Jsonify::JsonValue do
  describe Jsonify::JsonTuple do
    let(:tuple) { Jsonify::JsonTuple.new('key',Jsonify::JsonString.new('value')) }
    it 'should be constructed of a key and value' do
      tuple.key.should == 'key'
      # tuple.value.should == 
    end
    it 'should evaluate to key:value' do
      tuple.evaluate.should == "\"key\":\"value\""
    end
  end
  
end