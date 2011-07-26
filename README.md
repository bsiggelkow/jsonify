# Jsonify

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

There are other good libraries available that help solve this problem, such as Tokamak and RABL, that allow the developer to specify the representation in one format that is then interpreted into the wanted format at runtime.
Please take a look at these projects when you consider alternatives; however, its my opinion that they are substantial and inherent differences between XML and JSON.

These differences may force the developer make concessions in one format to make the other format correct.

But an even greater motivation for me was emulating the simplicity of Builder. I have not found a single framework for JSON that provides the simplicity and elegance of Builder. Jsonify is my attempt at remedying that situation.

___more coming soon___

## Installation

gem install jsonify

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

Jsonify includes Rails 3 template handler. Rails will handle any template with a ___.jsonify___ extension with Jsonify.
The Jsonify template handler exposes the `Jsonify::Builder` instance to your template with the `json` variable as in the following example:

    json.hello do
      json.world "Jsonify is Working!"
    end

## Documentation

[Jsonify Yard Docs](http://rubydoc.info/github/bsiggelkow/jsonify/master/frames)

## Build Status

[Compliments of Travis](http://travis-ci.org/bsiggelkow/jsonify)

## TODOs
1. Consider simplified means of creating arrays (e.g. json.links(@links) {|link| ...})
1. Benchmark performance

## Roadmap

1. Split Rails template handling into separate gem
1. Add support for Sinatra and Padrino (maybe separate gems)

## License

This project is released under the MIT license.

## Authors

* [Bill Siggelkow](https://github.com/bsiggelkow)
