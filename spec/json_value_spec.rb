require 'spec_helper'

describe Jsonify::JsonValue do

  describe Jsonify::JsonPair do
    let(:pair) { Jsonify::JsonPair.new('key','value') }
    it 'should be constructed of a key and value' do
      pair.key.should == 'key'
    end
    it 'should evaluate to key:value' do
      pair.to_json.should == "\"key\":\"value\""
    end
  end

  describe Jsonify::JsonTrue do
    it 'should have a value of true' do
      Jsonify::JsonTrue.new.to_json.should == 'true'
    end
  end

  describe Jsonify::JsonFalse do
    it 'should have a value of false' do
      Jsonify::JsonFalse.new.to_json.should == 'false'
    end
  end

  describe Jsonify::JsonNull do
    it 'should have a value of true' do
      Jsonify::JsonNull.new.to_json.should == 'null'
    end
  end

  describe 'strings' do
    it 'should quote the value' do
      'foo'.to_json.should == "\"foo\""
    end
    it 'should encode unicode' do
      unicode = 'goober'.concat(16)
      unicode.to_json.should == "\"goober\\u0010\""
    end
  end


end