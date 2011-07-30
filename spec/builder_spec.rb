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

        # Hackery to come up with a failing case
        class TestBuilder < Jsonify::Builder
          attr_accessor :stack
        end
        class FooBar
          def evaluate
            "foobar"
          end
        end

        json = TestBuilder.new(:verify => true)
        json.stack << FooBar.new
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
        JSON.parse(json.compile!).should == JSON.parse('{"foo":"bar","no":"whar"}')
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
      json.compile!.should == "[{\"foo\":\"bar\"},{\"go\":\"far\"}]"
    end
  end
  
  describe 'objects' do
    it 'simple object should work' do
      json.foo :bar
      json.go :far
      json.compile!.should ==  "{\"foo\":\"bar\",\"go\":\"far\"}"
    end
    it 'should handle arrays' do
      json[1] = [2, 3]
      json[4] = 5
      json.compile!.should ==  '{"1":[2,3],"4":5}'
    end
  end
  
  describe 'using blocks' do

    it 'should allow names with spaces using tag!' do
      json.tag!("foo foo") do
        json.tag!("bar bar") do
          json.tag!('buzz buzz','goo goo')
        end
      end
      json.compile!.should == "{\"foo foo\":{\"bar bar\":{\"buzz buzz\":\"goo goo\"}}}"
    end

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
        json << 1
        json << 2
      end
      json.compile!.should == "{\"foo\":[1,2]}"
    end
    
    it 'hash with array by iteration' do
      ary = [1,2,3]
      json.foo(ary) do |n|
        n * 2
      end 
      json.compile!.should ==  "{\"foo\":[2,4,6]}"
    end
    
    it 'simple array with object' do
      json << 1
      json << {:foo => :bar}
      json.compile!.should == "[1,{\"foo\":\"bar\"}]"
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
      JSON.parse(json.compile!).should == JSON.parse(expected)
    end
  end
  
  describe 'without blocks' do

    describe 'complex array' do
      it 'should work' do
        json.bar [1,2,{:foo => 'goo'}]
        json.compile!.should == "{\"bar\":[1,2,{\"foo\":\"goo\"}]}"
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
          { :href => link.url, :rel => link.type}
        end
      end
      expected = "{\"result\":{\"person\":{\"fname\":\"George\",\"lname\":\"Burdell\"},\"links\":[{\"href\":\"example.com\",\"rel\":\"self\"},{\"href\":\"foo.com\",\"rel\":\"parent\"}]}}"
      JSON.parse(json.compile!).should == JSON.parse(expected)
    end
  end
  
  describe 'ingest!' do
    context 'json object' do
      let(:json_string) { '{"my girl":"Friday","my daughter":"Wednesday"}' }
      context 'into' do
        it 'nothing -- should replace it' do
          json.ingest! json_string
          JSON.parse(json.compile!).should == JSON.parse(json_string)
        end
        it 'json object -- should merge' do
          json["my boy"] = "Monday"
          json["my girl"] = "Sunday"
          json.ingest! json_string
          expected = '{"my boy":"Monday","my girl":"Friday","my daughter":"Wednesday"}'
          JSON.parse(json.compile!).should == JSON.parse(expected)
        end
        it 'json array -- should add' do
          json << 1 << 2
          json.ingest! json_string
          expected = '[1,2,{"my girl":"Friday","my daughter":"Wednesday"}]'
          JSON.parse(json.compile!).should == JSON.parse(expected)
        end
      end
    end
  end
end