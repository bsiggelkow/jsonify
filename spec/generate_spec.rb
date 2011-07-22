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
    result.evaluate.should == '{"links":[{"rel":"foo","href":"goo"},{"rel":"bar","href":"baz"}]}'
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
      json.evaluate.should == "{\"links\":[{\"rel\":\"foo\",\"href\":\"goo\"},{\"rel\":\"bar\",\"href\":\"baz\"}]}"
    end
  end
end