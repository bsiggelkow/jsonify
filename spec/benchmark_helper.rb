require "benchmark"
require "rspec"

module RSpec
  module Benchmark
    class Result
      attr_accessor :slowest, :fastest, :average, :elapsed

      def initialize(elapsed)
        @elapsed = elapsed
        @slowest = elapsed.max
        @fastest = elapsed.min
        @average = elapsed.inject(0) {|b, t| b + t} / elapsed.size
      end

      def to_s
        "[average: #{average}, slowest: #{slowest}, fastest: #{fastest}]"
      end
    end

    # Run a given block and calculate the average execution time.
    # The block will be executed 1000 times by default.
    #
    #   benchmark { do something }
    #   benchmark(100) { do something }
    #
    def benchmark(times = 1_000, &block)
      elapsed = (1..times).collect do
        GC.start
        ::Benchmark.realtime(&block) * 1000
      end

      Result.new(elapsed)
    end
  end
end

# Check if the slowest execution is less than expected.
#
#   it "should do something fast" do
#     benchmark { do something }.should be_faster_than(1.3)
#   end
#
RSpec::Matchers.define :be_faster_than do |expected|
  match do |result|
    result.slowest < expected
  end
end

# Check if the slowest execution is greater than expected.
#
#   it "should do something slow" do
#     benchmark { do something }.should_not be_slower_than(1.3)
#   end
#
RSpec::Matchers.define :be_slower_than do |expected|
  match do |result|
    result.slowest > expected
  end
end

# Check if the execution average is close to expected.
#
#   it "should do something average time" do
#     benchmark { do something }.should be_on_average(1.3, 0.01)
#   end
#
RSpec::Matchers.define :be_on_average do |expected, delta|
  match do |result|
    (result.average - expected).abs < delta
  end
end

# Include matchers and <tt>benchmark</tt> method into RSpec context.
RSpec.configure do |config|
  config.include(RSpec::Benchmark)
end

if ARGV[0] == __FILE__
  describe RSpec::Benchmark do
    before do
      GC.stub(:start)
    end

    it "should be faster than expected" do
      stub(:slowest => 0.01).should be_faster_than(0.5)
    end

    it "should not be faster than expected" do
      stub(:slowest => 2).should_not be_faster_than(0.5)
    end

    it "should be slower than expected" do
      stub(:slowest => 2).should be_slower_than(0.5)
    end

    it "should not be slower than expected" do
      stub(:slowest => 0.5).should_not be_slower_than(2)
    end

    it "should be on average" do
      stub(:average => 0.51).should be_on_average(0.5, 0.019)
      stub(:average => 0.49).should be_on_average(0.5, 0.019)
    end

    it "should call garbage collector" do
      GC.should_receive(:start).exactly(5).times
      benchmark(5) { true }
    end

    it "should return result with collected data" do
      result = benchmark(5) { true }

      result.average.should be_kind_of(Float)
      result.slowest.should be_kind_of(Float)
      result.fastest.should be_kind_of(Float)
    end

    it "should run block" do
      object = mock
      object.should_receive(:run).exactly(1000).times

      benchmark { object.run }
    end

    it "should run block with custom range" do
      object = mock
      object.should_receive(:run).exactly(3).times

      benchmark(3) { object.run }
    end
  end
end