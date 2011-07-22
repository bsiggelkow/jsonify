require 'spec_helper'

describe Jsonify::Builder do
  
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
    it 'hash with array' do
      json.foo do
        json.array! do |ary|
          ary << 1
          ary << 2
        end
      end
      json.compile!.should == "{\"foo\":[1,2]}"
    end
    
    it 'simple array' do
      json.array! do |ary|
        ary << 1
        ary << 2
      end
      json.compile!.should == "[1,2]"
    end

    it 'simple array with object' do
      json.array! do |ary|
        ary << 1
        json.foo :bar
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
    let(:json) { Jsonify::Builder.new }
    describe 'complex array' do
      it 'should work' do
        json.bar [1,2,{:foo => 'goo'}]
        json.compile!.should == "{\"bar\":[1,2,{\"foo\":\"goo\"}]}"
      end
    end
  end
  
  describe 'super complex example' do
    let(:json) { Jsonify::Builder.new }
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

    # TODO -- Make map! work 
    #
    # it 'should work using map! with argument' do
    #   json.result do
    #     json.person do
    #       json.fname 'George'
    #       json.lname 'Burdell'
    #     end
    #     json.links do
    #       json.map!(links) do |link|
    #         { href: link.url, rel: link.type}
    #       end
    #     end
    #   end
    #   expected = "{\"result\":{\"person\":{\"fname\":\"George\",\"lname\":\"Burdell\"},\"links\":[{\"href\":\"example.com\",\"rel\":\"self\"},{\"href\":\"foo.com\",\"rel\":\"parent\"}]}}"
    #   json.compile!.should == expected
    # end
  end
end