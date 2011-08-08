
module Jsonify

  class Template < Tilt::Template
    self.default_mime_type = 'application/json'

    def self.engine_initialized?
      defined? ::Jsonify
    end

    def initialize_engine
      require_template_library 'jsonify'
    end

    def prepare; end

    def evaluate(scope, locals, &block)
      return super(scope, locals, &block) if data.respond_to?(:to_str)
      json = ::Jsonify::Builder.new
      data.call(json)
      json.compile!
    end

    def precompiled_preamble(locals)
      return super if locals.include? :json
      "json = ::Jsonify::Builder.new\n#{super}"
    end

    def precompiled_postamble(locals)
      "json.compile!"
    end

    def precompiled_template(locals)
      data.to_str
    end
  end

end
