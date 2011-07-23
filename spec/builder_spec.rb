require 'spec_helper'

describe Jsonify::Builder do

  let(:json) { Jsonify::Builder.new }

  describe 'base behavior' do
    describe 'should render empty object on literal' do
      it 'after initialization' do
        json.compile!.should == "{}"
      end
      it 'after reset' do
        json.foo 'bar'
        json.reset!
        json.compile!.should == "{}"
      end
    end
    describe 'with verify set' do
      it 'should report a parse error if the result is not parseable' do
        json = Jsonify::Builder.new(:verify => true)
        # Hackery to come up with a failing case
        class FooBar
          def evaluate
            "foobar"
          end
        end
        json.instance_variable_set(:@stack, [FooBar.new])
        lambda{ json.compile! }.should raise_error(JSON::ParserError)
      end
    end
    describe 'unicode characters' do
      it 'should properly encode' do
        json = Jsonify::Builder.new(:verify => true)
        json.foo 'bar'.concat(16)
        lambda { json.compile! }.should_not raise_error
      end
    end
    describe "pretty printing" do
      it "should not be pretty by default" do
        json.foo do
          json.bar 'baz'
        end
        non_pretty_results = '{"foo":{"bar":"baz"}}'
        json.compile!.should == non_pretty_results
      end
      it "should be pretty when asked for" do
        json = Jsonify::Builder.new(:pretty => true)
        json.foo do
          json.bar 'baz'
        end
        pretty_results = <<PRETTY_JSON
{
  "foo": {
    "bar": "baz"
  }
}
PRETTY_JSON
        json.compile!.should == pretty_results.chomp
      end
    end
  end
  
  describe 'arrays' do
    it 'simple array should work' do
      json.array! do |ary|
        ary << 1
        ary << 2
      end
      json.compile!.should == "[1,2]"
    end
    it 'array of arrays should work' do
      json.array! do |ary|
        ary << json.array! {|a| a << 1}
        ary << json.array! {|b| b << 2}
        ary << 3
      end
      json.compile!.should == "[[1],[2],3]"
    end
    it 'array of hashes should work' do
      json.array! do |ary|
        ary << {foo: :bar}
        ary << {go:  :far}
      end
      json.compile!.should == "[{\"foo\":\"bar\"},{\"go\":\"far\"}]"
    end
  end
  
  describe 'objects' do
    it 'simple object should work' do
      json.object! do |obj|
        obj << [:foo,:bar]
        obj << [:go, :far]
      end
      json.compile!.should ==  "{\"foo\":\"bar\",\"go\":\"far\"}"
    end
    it 'should treat the first element of an array as a key' do
      json.object! do |obj|
        obj << [1, 2, 3]
        obj << [4, 5]
      end
      json.compile!.should ==  '{"1":[2,3],"4":5}'
    end
  end
  
  describe 'using blocks' do
    
    it 'complex hash' do
      json.foo do
        json.bar do
          json.baz 'goo'
        end
      end
      json.compile!.should == "{\"foo\":{\"bar\":{\"baz\":\"goo\"}}}"
    end
    it 'simple hash' do
      json.foo do
        json.baz :goo
      end
      json.compile!.should == "{\"foo\":{\"baz\":\"goo\"}}"
    end
    it 'hash with array' do
      json.foo do
        json.array! do |ary|
          ary << 1
          ary << 2
        end
      end
      json.compile!.should == "{\"foo\":[1,2]}"
    end
    
    it 'simple array with object' do
      json.array! do |ary|
        ary << 1
        ary << (json.foo 'bar')
      end
      json.compile!.should == "[1,{\"foo\":\"bar\"}]"
    end

    it 'complex hash with array' do
      json.foo do
        json.bar do
          json.baz 'goo'
          json.years do
            json.array! do |ary|
              ary << 2011
              ary << 2012
            end
          end
        end
      end
      json.compile!.should == "{\"foo\":{\"bar\":{\"baz\":\"goo\",\"years\":[2011,2012]}}}"
    end
  end
  
  describe 'without blocks' do
    describe 'complex array' do
      it 'should work' do
        json.bar [1,2,{:foo => 'goo'}]
        json.compile!.should == "{\"bar\":[1,2,{\"foo\":\"goo\"}]}"
      end
    end
  end
  
  describe 'super complex example' do
    let(:links) { 
      link_class = Struct.new(:url,:type)
      [ 
        link_class.new('example.com', 'self'),
        link_class.new('foo.com',     'parent')
      ]
    }
    it 'should work using array!' do
      json.result do
        json.person do
          json.fname 'George'
          json.lname 'Burdell'
        end
        json.links do
          json.array! do |ary|
            links.each do |link|
              ary << { href: link.url, rel: link.type}
            end
          end
        end
      end
      expected = "{\"result\":{\"person\":{\"fname\":\"George\",\"lname\":\"Burdell\"},\"links\":[{\"href\":\"example.com\",\"rel\":\"self\"},{\"href\":\"foo.com\",\"rel\":\"parent\"}]}}"
      json.compile!.should == expected
    end

    [:map!, :collect!].each do |method|
      it "should work using #{method} with argument" do
        json.result do
          json.person do
            json.fname 'George'
            json.lname 'Burdell'
          end
          json.links do
            json.send(method,links) do |link|
              { href: link.url, rel: link.type}
            end
          end
        end
        expected = "{\"result\":{\"person\":{\"fname\":\"George\",\"lname\":\"Burdell\"},\"links\":[{\"href\":\"example.com\",\"rel\":\"self\"},{\"href\":\"foo.com\",\"rel\":\"parent\"}]}}"
        json.compile!.should == expected
      end
    end
  end
  
  
end