require 'spec_helper'

describe Jsonify::Builder do
  
  let(:j) { Jsonify::Builder.new }
  
  describe 'hello world' do
    it "runs under 0.3 milliseconds" do
      benchmark do
        j.hello 'world'
        j.compile!
        j.reset!
      end.should be_faster_than( 0.3 ) #milliseconds
    end
  end
  
  
  describe 'json_builder example' do
    it 'should be better than builder (0.5 milliseconds)' do
      benchmark do
        j.name "Garrett Bjerkhoel"
        j.birthday Time.local(1991, 9, 14)
        j.street do
          j.address "1143 1st Ave"
          j.address2 "Apt 200"
          j.city "New York"
          j.state "New York"
          j.zip 10065
        end
        j.skills do
          j.ruby true
          j.asp false
          j.php true
          j.mysql true
          j.mongodb true
          j.haproxy true
          j.marathon false
        end
        j.single_skills ['ruby', 'php', 'mysql', 'mongodb', 'haproxy']
        j.booleans [true, true, false, nil]
        j.reset!
      end.should be_faster_than(0.5)
    end
  end

end