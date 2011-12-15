require 'spec_helper'

describe Jsonify::Builder do

  let(:json) { Jsonify::Builder.new }
  
  describe 'class methods' do
    it '#compile should compile' do
      Jsonify::Builder.compile do |j|
        j.foo 'bar'
      end.should == '{"foo":"bar"}'
    end
    it '#pretty should be pretty' do
      pretty_results = <<PRETTY_JSON
{
  "foo": {
    "bar": "baz"
  }
}
PRETTY_JSON
      Jsonify::Builder.pretty do |j|
        j.foo do
          j.bar 'baz'
        end
      end.should == pretty_results.chomp
    end
    it '#plain should be plain' do
      Jsonify::Builder.plain do |j|
        j.foo 'bar'
      end.should == '{"foo":"bar"}'
    end
  end

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

        # Hackery to come up with a failing case
        class TestBuilder < Jsonify::Builder
          attr_accessor :stack
        end
        class FooBar
          def encode_as_json
            "foobar"
          end
        end

        json = TestBuilder.new(:verify => true)
        json.stack << FooBar.new
        lambda{ json.compile! }.should raise_error(MultiJson::DecodeError)
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
        json = Jsonify::Builder.new(:format => :pretty)
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
    
    describe 'array creation' do
      it 'with the append operator (<<)' do
        json << 1 << 2
        json.compile!.should == "[1,2]"
      end
      it 'with the append! method' do
        json.append!( 1,2 ).append! 3
        json.compile!.should == "[1,2,3]"
      end
    end
    describe 'object creation' do
      it 'should support the element assignment operator( []= )' do
        json["foo"] = 'bar'
        json.compile!.should == '{"foo":"bar"}'
      end
      it 'should support the store! message' do
        json.store!( "foo", "bar" ).store!( 'no',  "whar" )
        MultiJson.decode(json.compile!).should == MultiJson.decode('{"foo":"bar","no":"whar"}')
      end
    end
  end
  
  describe 'arrays' do
    it 'simple array should work' do
      json << 1
      json << 2
      json.compile!.should == "[1,2]"
    end
    it 'array of arrays should work' do
      json << [1]
      json << [2]
      json << [3]
      json.compile!.should == "[[1],[2],[3]]"
    end
    it 'array of hashes should work' do
      json << {:foo => :bar}
      json << {:go  => :far}
      json.compile!.should == '[{"foo":"bar"},{"go":"far"}]'
    end
  end
  
  describe 'objects' do
    it 'simple object should work' do
      json.foo :bar
      json.go :far
      expected = '{"foo":"bar","go":"far"}'
      MultiJson.decode(json.compile!).should ==  MultiJson.decode(expected)
    end
    it 'should handle arrays' do
      json[1] = [2, 3]
      json[4] = 5
      MultiJson.decode(json.compile!).should ==  MultiJson.decode('{"1":[2,3],"4":5}')
    end
  end
  
  describe 'using blocks' do

    it 'should allow names with spaces using tag!' do
      json.tag!("foo foo") do
        json.tag!("bar bar") do
          json.tag!('buzz buzz','goo goo')
        end
      end
      expected = '{"foo foo":{"bar bar":{"buzz buzz":"goo goo"}}}'
      MultiJson.decode(json.compile!).should == MultiJson.decode(expected)
    end

    it 'complex hash' do
      json.foo do
        json.bar do
          json.baz 'goo'
        end
      end
      json.compile!.should == '{"foo":{"bar":{"baz":"goo"}}}'
    end

    it 'simple hash' do
      json.foo do
        json.baz :goo
      end
      json.compile!.should == '{"foo":{"baz":"goo"}}'
    end

    it 'hash with array' do
      json.foo do
        json << 1
        json << 2
      end
      json.compile!.should == '{"foo":[1,2]}'
    end
    
    it 'hash with array by iteration' do
      ary = [1,2,3]
      json.foo do
        ary.each do |n|
          json << (n * 2)
        end
      end 
      json.compile!.should ==  '{"foo":[2,4,6]}'
    end

    it 'simple array with object' do
      json << 1
      json << {:foo => :bar}
      json.compile!.should == '[1,{"foo":"bar"}]'
    end
    
    it 'simple array with object via method_missing' do
      json << 1
      json << 2
      json.foo :bar
      json.compile!.should == "[1,2,{\"foo\":\"bar\"}]"
    end

    it 'complex hash with array' do
      json.foo do
        json.bar do
          json.baz 'goo'
          json.years do
            json << 2011
            json << 2012
          end
        end
      end
      expected = "{\"foo\":{\"bar\":{\"baz\":\"goo\",\"years\":[2011,2012]}}}"
      MultiJson.decode(json.compile!).should == MultiJson.decode(expected)
    end
  end
  
  describe 'without blocks' do

    describe 'complex array' do
      it 'should work' do
        json.bar [1,2,{:foo => 'goo'}]
        expected = "{\"bar\":[1,2,{\"foo\":\"goo\"}]}"
        MultiJson.decode(json.compile!).should == MultiJson.decode(expected)
      end
    end

    describe 'object with null' do
      it 'should handle missing argument' do
        json.foo
        json.compile!.should == '{"foo":null}'
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
    it 'should work using arrays' do
      json.result do
        json.person do
          json.fname 'George'
          json.lname 'Burdell'
        end
        json.links(links) do |link|
          json.href link.url
          json.rel link.type
        end
      end
      expected = "{\"result\":{\"person\":{\"fname\":\"George\",\"lname\":\"Burdell\"},\"links\":[{\"href\":\"example.com\",\"rel\":\"self\"},{\"href\":\"foo.com\",\"rel\":\"parent\"}]}}"
      MultiJson.decode(json.compile!).should == MultiJson.decode(expected)
    end
  end
  
  describe 'ingest!' do
    context 'a json object' do
      let(:json_string) { '{"my girl":"Friday","my daughter":"Wednesday"}' }
      context 'into' do
        it 'nothing -- should replace it' do
          json.ingest! json_string
          MultiJson.decode(json.compile!).should == MultiJson.decode(json_string)
        end
        it 'json object -- should merge' do
          json["my boy"] = "Monday"
          json["my girl"] = "Sunday"
          json.ingest! json_string
          expected = '{"my boy":"Monday","my girl":"Friday","my daughter":"Wednesday"}'
          MultiJson.decode(json.compile!).should == MultiJson.decode(expected)
        end
        it 'json array -- should add' do
          json << 1 << 2
          json.ingest! json_string
          expected = '[1,2,{"my girl":"Friday","my daughter":"Wednesday"}]'
          MultiJson.decode(json.compile!).should == MultiJson.decode(expected)
        end
      end
    end
    context 'a json array' do
      let(:json_string) { '[1,2,3]' }
      context 'into' do
        it 'nothing -- should replace it' do
          json.ingest! json_string
          MultiJson.decode(json.compile!).should == MultiJson.decode(json_string)
        end
        it 'json object -- should raise error' do
          json["my boy"] = "Monday"
          json["my girl"] = "Sunday"
          lambda{ json.ingest! json_string }.should raise_error( ArgumentError )
        end
        it 'json array -- should add' do
          json << 1 << 2
          json.ingest! json_string
          expected = '[1,2,[1,2,3]]'
          MultiJson.decode(json.compile!).should == MultiJson.decode(expected)
        end
      end
    end
  end

  describe 'with new array style' do
    it 'should work' do
      results =[
        {:id => 1, :kids => [{:id => 'a'},{:id => 'b'}]},
        {:id => 2, :kids => [{:id => 'c'},{:id => 'd'}]},
      ]

      json.results(results) do |result|
        json.id result[:id]
        json.children(result[:kids]) do |kid|
          json.id kid[:id]
        end
      end
      
      expected = '{"results":[{"id":1,"children":[{"id":"a"},{"id":"b"}]},{"id":2,"children":[{"id":"c"},{"id":"d"}]}]}'
      MultiJson.decode(json.compile!).should == MultiJson.decode(expected)
    end
    it 'simple append' do
      json.letters('a'..'c') do |letter|
        json << letter.upcase
      end
      expected = '{"letters":["A","B","C"]}'
      MultiJson.decode(json.compile!).should == MultiJson.decode(expected)
    end
    
  end
end
