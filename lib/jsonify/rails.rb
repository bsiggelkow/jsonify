require 'action_view'

module ActionView
  module Template::Handlers
    class JsonifyBuilder < Template::Handler
      include Compilable

      self.default_format = Mime::JSON

      def compile(template)
        "json = ::Jsonify::Builder.new();" +
          template.source +
        ";json.compile!;"
      end
    end
  end
end

ActionView::Template.register_template_handler :jsonify, ActionView::Template::Handlers::JsonifyBuilder
