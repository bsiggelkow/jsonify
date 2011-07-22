require 'spec_helper'

describe Jsonify::JsonValue do
  describe Jsonify::JsonPair do
    let(:pair) { Jsonify::JsonPair.new('key',Jsonify::JsonString.new('value')) }
    it 'should be constructed of a key and value' do
      pair.key.should == 'key'
      # pair.value.should == 
    end
    it 'should evaluate to key:value' do
      pair.evaluate.should == "\"key\":\"value\""
    end
  end
  
end