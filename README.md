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

In the examples that follow, the JSON output is usually shown "prettified". Is this only
for illustration purposes, as the default behavior for Jsonify is not to prettify the output.
You can enable prettification by passing `:pretty => true` to the Jsonify::Builder constructor; however,
pretty printing is a relatively costly operation and should not be used in production (unless, of course, you explicitly
want to show this format).

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

  * __object__: a collection of name-value pairs -- in Jsonify this is a `JsonObject`
  * __array__: an ordered list of values -- in Jsonify this is a `JsonArray`
  
Jsonify adheres to the JSON specification and provides explicit support 
for working with these primary structures. At the top most level, a JSON string
must be one of these structures and Jsonify ensures that this condition is met.

#### JSON Objects

A JSON object, sometimes
referred to as an ___object literal___, is a common structure familiar
to most developers. Its analogous to the nested element structured common
in XML. The [JSON RFC](http://www.ietf.org/rfc/rfc4627.txt) states that 
"the names within an object SHOULD be unique". Jsonify elevates this recommendation
by backing the JsonObject with a `Hash`; an object must have unique keys and the last one in, wins.

    json = Jsonify::Builder.new
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

    json = Jsonify::Builder.new
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

#### JSON Arrays

A JSON array is an ordered list of JSON values. A JSON value can be a simple value,
like a string or a number, or a supported JavaScript primitive like true, false, or null.
A JSON value can also be a JSON object or another JSON array. Jsonify strives to make
this kind of construction possible in a buider-style.

Jsonify supports JSON array construction through two approaches: `method_missing` and `append!`.

##### method_missing

Pass an array and a block to `method_missing` (or `tag!`), and Jsonify will iterate
over that array, and create a JSON array where each array item is the result of the block.
If you pass an array that has a length of 5, you will end up with a JSON array that has 5 items.
That JSON array is then set as the value of the name-value pair, where the name comes from the method name (for `method_missing`)
or symbol (for `tag!`).

So this construct is really doing two things -- creating a JSON pair, and creating a JSON array as the value of the pair.

    json = Jsonify::Builder.new(:pretty => true)
    json.letters('a'..'c') do |letter|
      letter.upcase
    end
    
compiles to ...

    {
      "letters": [
        "A",
        "B",
        "C"
      ]
    }

Another way to handle this particular example is to get rid of the block entirely. 
Simply pass the array directly &mdash; the result will be the same.

    json.letters ('a'..'c').map(&:upcase)

##### append!

But what if we don't want to start with an object? How do we tell Jsonify to start with an array instead?

You can use `append!` (passing one or more values), or `<<` (which accepts only a single value) to
the builder and it will assume you are adding values to a JSON array.

    json.append! 'a'.upcase, 'b'.upcase, 'c'.upcase

    [
      "A",
      "B",
      "C"
    ]

or more idiomatically ...

    json.append! *('a'..'c').map(&:upcase)

The append ___operator___, `<<`, can be used to push a single value into the array:

    json = Jsonify::Builder.new
    json << 'a'.upcase
    json << 'b'.upcase
    json << 'c'.upcase
    
Of course, standard iteration works here as well ...

    json = Jsonify::Builder.new
    ('a'..'c').each do |letter|
      json << letter.upcase
    end

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
1. Clean up specs

## Roadmap

1. Split Rails template handling into separate gem
1. Add support for Sinatra and Padrino (maybe separate gems)

## License

This project is released under the MIT license.

## Authors

* [Bill Siggelkow](https://github.com/bsiggelkow)
