require 'spec_helper'

describe Jsonify::Builder do
  let(:links) do
    { :links => 
       [
         {:rel => 'foo', :href => 'goo'},
         {:rel => 'bar', :href => 'baz'}
       ]
    }
  end
  it 'should build json' do
    json = Jsonify::Builder.new
    result = json.build! links
    result.evaluate.should == '{"links":[{"rel":"foo","href":"goo"},{"rel":"bar","href":"baz"}]}'
  end

  describe 'complex example' do
    let(:jsonifier) { Jsonify::Builder.new }
    # lets represent a set of links
    # { links : 
    #    [
    #      {:rel='foo', :href='goo'},
    #      {:rel='bar', :href='baz'}
    #    ]
    # }
    
    
    it 'should work' do
      json = jsonifier.object!( 
        {"links" =>
          jsonifier.array!([
            jsonifier.object!( {"rel" => "foo", "href" => "goo"} ),
            jsonifier.object!( {"rel" => "bar", "href" => "baz"} )
          ])
        }
      )
      json.evaluate.should == "{\"links\":[{\"rel\":\"foo\",\"href\":\"goo\"},{\"rel\":\"bar\",\"href\":\"baz\"}]}"
    end
  end
  
  describe 'using blocks' do
    let(:json) { Jsonify::Builder.new }
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
  end
  
  describe 'without blocks' do
    let(:json) { Jsonify::Builder.new }
    describe 'complex array' do
      it 'should work' do
        json.bar [1,2,{:foo => 'goo'}]
        json.compile!.should == "{\"bar\":[1,2,{\"foo\":\"goo\"}]}"
      end
    end
  end
end