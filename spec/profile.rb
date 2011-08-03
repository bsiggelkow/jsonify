require 'bundler'
require 'bundler/setup'
require 'jsonify'
require 'ruby-prof'

result = RubyProf.profile do
  1.times do
    json=Jsonify::Builder.new
    json.hello 'world'
    json.compile!
  end
end

# Print a flat profile to text
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)