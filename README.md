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

___coming soon___

## Usage

### Standalone

    require 'jsonify'
    json = Jsonify::Builder.new
  
    person = Struct.new(:first_name,:last_name).new('George','Burdell')
    links = [
      ['self',   'http://example.com/people/123'],
      ['school', 'http://gatech.edu'],
    ]

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

___coming soon___

## License

This project is released under the MIT license.

## Authors

* [Bill Siggelkow](https://github.com/bsiggelkow)
