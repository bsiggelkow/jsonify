require 'bundler'
require 'bundler/setup'
require 'jsonify'
require 'benchmark'

class Speed
  def self.test
    Benchmark.bm do |b|
      b.report('Jsonify') do
        15_000.times {
          j = Jsonify::Builder.new
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
          j.compile!
        }
      end
    end
  end
end

Speed.test