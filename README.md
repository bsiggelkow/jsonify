# Jsonify

[Jsonify](https://github.com/bsiggelkow/jsonify) Jsonify is to JSON as [Builder](https://github.com/jimweirich/builder) is to XML.

## Goal

Jsonify provides a ___builder___ style engine for creating correct JSON representations of Ruby objects.

Jsonify hooks into Rails ActionView to allow you to create JSON view templates in much the same way that you can use Builder for XML templates.

## Motivation

JSON and XML are without a doubt the most common representations used by RESTful applications. Jsonify was built around the notion that these representations belong in the ___view___ layer of the application.
For XML representations, Rails makes this easy through its support of Builder templates, but, when it comes to JSON, there is no clear approach.

___more coming soon___

## Installation

gem install jsonify

## Usage

### Standalone
```ruby
  # Create some objects that represent a person and associated hyperlinks
  person = Struct.new(:first_name,:last_name).new('George','Burdell')
  links = [
    ['self',   'http://example.com/people/123'],
    ['school', 'http://gatech.edu'],
  ]

  # Build this information as JSON
  require 'jsonify'
  json = Jsonify::Builder.new(:pretty => true)

  json.result do
    json.alumnus do
      json.fname person.first_name
      json.lname person.last_name
    end
    json.links do
      json.map!(links) do |link|
        {:rel => link.first, :href => link.last}
      end
    end
  end

  # Evaluate the result to a string
  json.compile!
```

Results in ...
```javascript  
    {
      "result": {
        "alumnus": {
          "fname": "George",
          "lname": "Burdell"
        },
        "links": [
          {
            "rel": "self",
            "href": "http://example.com/people/123"
          },
          {
            "rel": "school",
            "href": "http://gatech.edu"
          }
        ]
      }
    }
```

### View Templates

Jsonify includes Rails 3 template handler. Rails will handle any template with a ___.jsonify___ extension with Jsonify.

The Jsonify::Builder is exposed as ___json___ as in the following example:
```ruby
    json.hello do
      json.world "Jsonify is Working!"
    end
```

## Roadmap

1. Get folks interested
1. Add additional documentation (both README and YARD)
1. Add top-level "<<" method for general appending
1. Split Rails template handling into separate gem
1. Add support for Sinatra and Padrino (maybe separate gems)

## License

This project is released under the MIT license.

## Authors

* [Bill Siggelkow](https://github.com/bsiggelkow)
