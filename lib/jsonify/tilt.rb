require 'tilt'
require 'tilt/template'
require 'jsonify/template'

Tilt.register Jsonify::Template, 'jsonify'