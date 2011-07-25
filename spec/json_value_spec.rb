require 'spec_helper'

describe Jsonify::JsonValue do

  describe Jsonify::JsonPair do
    let(:pair) { Jsonify::JsonPair.new('key',Jsonify::JsonString.new('value')) }
    it 'should be constructed of a key and value' do
      pair.key.should == 'key'
    end
    it 'should evaluate to key:value' do
      pair.evaluate.should == "\"key\":\"value\""
    end
  end

  describe Jsonify::JsonTrue do
    it 'should have a value of true' do
      Jsonify::JsonTrue.new.evaluate.should == 'true'
    end
  end

  describe Jsonify::JsonFalse do
    it 'should have a value of false' do
      Jsonify::JsonFalse.new.evaluate.should == 'false'
    end
  end

  describe Jsonify::JsonNull do
    it 'should have a value of true' do
      Jsonify::JsonNull.new.evaluate.should == 'null'
    end
  end

  describe Jsonify::JsonNumber do
    it 'should accept an integer' do
      Jsonify::JsonNumber.new(1).evaluate.should == 1
    end
    it 'should accept a float' do
      Jsonify::JsonNumber.new(1.23).evaluate.should == 1.23
    end
  end

  describe Jsonify::JsonString do
    it 'should quote the value' do
      Jsonify::JsonString.new('foo').evaluate.should == "\"foo\""
    end
    it 'should encode unicode' do
      unicode = 'goober'.concat(16)
      Jsonify::JsonString.new(unicode).evaluate.should == "\"goober\\u0010\""
    end
  end


end