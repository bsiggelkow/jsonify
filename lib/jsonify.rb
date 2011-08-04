begin
  require 'json'
rescue LoadError
  raise "No JSON implementation found. Please install a JSON library of your choosing."
end
require 'jsonify/blank_slate'
require 'jsonify/version'
require 'jsonify/json_value'
require 'jsonify/generate'
require 'jsonify/builder'