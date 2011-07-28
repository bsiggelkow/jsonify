# Jsonify -- a builder for JSON <a href="http://travis-ci.org/bsiggelkow/jsonify"><img src="https://secure.travis-ci.org/bsiggelkow/jsonify.png" alt=""></a>

[Jsonify](https://github.com/bsiggelkow/jsonify) is to JSON as [Builder](https://github.com/jimweirich/builder) is to XML.

## Goal

Jsonify provides a ___builder___ style engine for creating correct JSON representations of Ruby objects.

Jsonify hooks into Rails ActionView to allow you to create JSON view templates in much the same way that you can use Builder for XML templates.

## Motivation

JSON and XML are without a doubt the most common representations used by RESTful applications. Jsonify was built around the notion that these representations belong in the ___view___ layer of the application.
For XML representations, Rails makes this easy through its support of Builder templates, but, when it comes to JSON, there is no clear approach.

For many applications, particularly those based on legacy database, its not uncommon to expose the data in more client-friendly representations than would be presented by the default Rails `to_json` method.
Rails does provide control of the emitted via a custom implementation of `as_json`.
Nevertheless, this forces the developer to place this code into the model when it more rightly belongs in the view.

When someone asks "Where are the model representations defined?", I don't want to have to say "Well, look in the views folder for XML, but you have to look at the code in the model for the JSON format."

There are a number of <a href='#related'>other libraries</a> available that try to solve this problem. Some take a similar approach to Jsonify and provide a builder-style interface.
Others allow the developer to specify the representation using a common DSL that can generate both JSON and XML.
Please take a look at these projects when you consider alternatives. It's my opinion that there are substantial and inherent differences between XML and JSON; and that these differences may force the developer to make concessions in one format or the other.

But an even greater motivation for me was emulating the simplicity of [Builder](https://github.com/jimweirich/builder). I have not found a single framework for JSON that provides the simplicity and elegance of Builder. Jsonify is my attempt at remedying that situation.

## Installation

`gem install jsonify`

## Usage

### Standalone
    # Create some objects that represent a person and associated hyperlinks
    @person = Struct.new(:first_name,:last_name).new('George','Burdell')
    @links = [
      ['self',   'http://example.com/people/123'],
      ['school', 'http://gatech.edu'],
    ]

    # Build this information as JSON
    require 'jsonify'
    json = Jsonify::Builder.new(:pretty => true)

    json.result do
      json.alumnus do
        json.fname @person.first_name
        json.lname @person.last_name
      end
      json.links(@links) do |link|
        {:rel => link.first, :href => link.last}
      end
    end

    # Evaluate the result to a string
    json.compile!

Results in ...

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

### View Templates

Jsonify includes Rails 3 template handler. Rails will handle any template with a `.jsonify` extension with Jsonify.
The Jsonify template handler exposes the `Jsonify::Builder` instance to your template with the `json` variable as in the following example:

    json.hello do
      json.world "Jsonify is Working!"
    end

### Usage Patterns

Jsonify is designed to support construction of an valid JSON representation and
is entirely based on the [JSON specification](http://json.org).

JSON is built on two fundamental structures: 
  - a collection of name-value pairs -- in Jsonify this is a `JsonObject`
  - an ordered list of values -- in Jsonify this is a `JsonArray`
  
Jsonify strictly adheres to the JSON specification and provides explicit support 
for working with these structures. A JSON representation can be either one of the
two fundamental structures and Jsonify supports both.

### JsonObject

A JSON object -- that is, a collection of name-value pairs, sometimes
referred to as an ___object literal___, is a natural structure thats familiar
to most developers. It readily maps to the nested element structured that we see
in XML. The [JSON RFC](http://www.ietf.org/rfc/rfc4627.txt) states that 
"the names within an object SHOULD be unique". Jsonify elevates this requirement
by backing the JsonObject with Hash; an object must have unique keys.

    json.person do # start a new JsonObject where the key is 'foo'
      json.name 'George Burdell' # add a pair to this object
      json.skills ['engineering','bombing'] # adds a pair with an array value
      json.name 'George P. Burdell'
    end

compiles to ...

    {
      "person": {
        "name": "George P. Burdell",
        "skills": [
          "engineering",
          "bombing"
        ]
      }
    }

It's perfectly legitimate for a JSON representation to simply be a collection
of name-value pairs without a ___root___ element. Jsonify supports this by
simply allowing you to specify the pairs that make up the object.

    json.location 'Library Coffeehouse'
    json.neighborhood 'Brookhaven'

compiles to ...

    {
      "location": "Library Coffeehouse",
      "neighborhood": "Brookhaven"
    }

If the ___name___ you want contains whitespace or other characters not allowed in a Ruby method name, use `tag!`.

    json.tag!("my location", 'Library Coffeehouse')
    json.neighborhood 'Brookhaven'

compiles to ...

    {
      "my location": "Library Coffeehouse",
      "neighborhood": "Brookhaven"
    }


## Documentation

[Yard Docs](http://rubydoc.info/github/bsiggelkow/jsonify/master/frames)

<a name='related'/>
<h2>Related Projects</h2>
- [Argonaut](https://github.com/jbr/argonaut)
- [JSON Builder](https://github.com/dewski/json_builder)
- [RABL](https://github.com/nesquena/rabl)
- [Tokamak](https://github.com/abril/tokamak)

## TODOs
1. Benchmark performance
1. Document how partials can be used

## Roadmap

1. Split Rails template handling into separate gem
1. Add support for Sinatra and Padrino (maybe separate gems)

## License

This project is released under the MIT license.

## Authors

* [Bill Siggelkow](https://github.com/bsiggelkow)
