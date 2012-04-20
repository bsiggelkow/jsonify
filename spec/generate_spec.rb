require 'spec_helper'

describe Jsonify::Generate do
  let(:links) do
    { :links => 
       [
         {:rel => 'foo', :href => 'goo'},
         {:rel => 'bar', :href => 'baz'}
       ]
    }
  end
  it 'should build json' do
    json = Jsonify::Generate
    result = json.value links
    expected = '{"links":[{"rel":"foo","href":"goo"},{"rel":"bar","href":"baz"}]}'
    MultiJson.load(result.encode_as_json).should == MultiJson.load(expected)
  end

  describe 'complex example' do
    let(:jsonifier) { Jsonify::Generate }
    
    it 'should work' do
      json = jsonifier.object_value( 
        {"links" =>
          jsonifier.array_value([
            jsonifier.object_value( {"rel" => "foo", "href" => "goo"} ),
            jsonifier.object_value( {"rel" => "bar", "href" => "baz"} )
          ])
        }
      )
      expected = "{\"links\":[{\"rel\":\"foo\",\"href\":\"goo\"},{\"rel\":\"bar\",\"href\":\"baz\"}]}"
      MultiJson.load(json.encode_as_json).should == MultiJson.load(expected)
    end
  end
end