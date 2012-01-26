# Jsonify &mdash; a builder for JSON [![Build Status](https://secure.travis-ci.org/bsiggelkow/jsonify.png)](http://travis-ci.org/bsiggelkow/jsonify)

[Jsonify](https://github.com/bsiggelkow/jsonify) is to JSON as [Builder](https://github.com/jimweirich/builder) is to XML. 

To use Jsonify for Rails templates, install [Jsonify-Rails](https://github.com/bsiggelkow/jsonify-rails).

## Goal

Jsonify provides a ___builder___ style engine for creating correct JSON representations of Ruby objects.

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

In the examples that follow, the JSON output is usually shown "prettified". This is only
for illustration purposes, as the default behavior for Jsonify is not to prettify the output.
You can enable prettification by passing `:format => :pretty` to the Jsonify::Builder constructor; however,
pretty printing is a relatively costly operation and should not be used in production (unless, of course, you explicitly
want to show this format). The default format, `plain`, dictates no special formatting: the result will be rendered as a compact string without any newlines.

### Compatibility Warning

Starting with version 0.2.0, the handling of arrays has changed to provide a more natural feel. As a consequence, however, code written using earlier versions of Jsonify may not work correctly. The example that follows demonstrates the changes you need to make.

Previously, when arrays were processed, you had to put away the builder-style, and use more conventional Rubyisms.

    json.links(@links) do |link|
      {:rel => link.type, :href => link.url}
    end

This difference was a frequent stumbling block with users and I wanted to remedy it. The interface for handling arrays is now consistent with the builder-style and should be less surprising to developers. The above snippet is now implemented as:

    json.links(@links) do |link|
      json.rel link.type
      json.href link.url
    end

As always, all feedback is greatly appreciated. I want to know how this new style works out.

### Standalone
    # Create some objects that represent a person and associated hyperlinks
    @person = Struct.new(:first_name,:last_name).new('George','Burdell')
    Link = Struct.new(:type, :url)
    @links = [
      Link.new('self', 'http://example.com/people/123'),
      Link.new('school', 'http://gatech.edu')
    ]

    # Build this information as JSON
    require 'jsonify'
    json = Jsonify::Builder.new(:format => :pretty)

    # Representation of the person
    json.alumnus do
      json.fname @person.first_name
      json.lname @person.last_name
    end

    # Relevant links
    json.links(@links) do |link|
      json.rel link.type
      json.href link.url
    end

    # Evaluate the result to a string
    json.compile!

Results in ...

    {
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

#### Convenience methods
Jsonify provides class-level convenience methods that
save you the trouble of instantiating the `Jsonify::Builder`. Each of these methods accepts a block, yields a new `Builder` object to the block, and then compiles the result.

- `compile`
  - Compiles the given block; any options are passed the instantiated `Builder`
- `pretty`
  - Compiles the given block; results are output in `pretty` format. 
- `plain`
  - Compiles the given block; results are output in `plain` (default) format. 

For example ...

    Jsonify::Builder.plain do |j|
      j.song 'Fearless'
      j.album 'Meddle'
    end

### Rails View Templates

Jsonify can be used for Rails 3 view templates via the [jsonify-rails](https://github.com/bsiggelkow/jsonify-rails) which includes a Rails 3 template handler. Any template with a `.jsonify` extension will be handled by Rails.

The Jsonify template handler exposes the `Jsonify::Builder` instance to your template with the `json` variable as in the following example:

    json.hello do
      json.world "Jsonify is Working!"
    end
    
Just like with any other template, your Jsonify template will have access to
any instance variables that are exposed through the controller. See [Jsonify-Rails](https://github.com/bsiggelkow/jsonify-rails) for additional details.

#### Partials

You can use partials from Jsonify views, and you can create Jsonify partials.  How your Jsonify template uses a partial depends on how the information the partial returns is structured. Keep in mind that any paritial, be it a Jsonify template, erb, or anything else, always a returns its result as a string.

##### Jsonify partials

Any Jsonify partial &mdash; that is, the file has a `.jsonify` extension &mdash;
will return, by design, a string that is valid JSON. It will represent either a JSON object,wrapped in curly braces ( {} ), or a JSON array, wrapped in square brackets ( [] ).

To incorporate such a value into a Jsonify template, use the `ingest!` method. 

`ingest!` assumes that the value it receives is valid JSON representation. It parses the JSON into a Jsonify object graph, and then adds it to the current Jsonify builder.

Let's assume this this is your main template, `index.jsonify`:

    json << 1
    json.ingest! (render :partial=>'my_partial')

From the first line, you can tell that an array will be created as this line uses the append operator.
On the second line, a partial is being added to the builder. Note that you cannot simply place `render :partial ...` on a line by itself as you can do with other templates like `erb` and `haml`. You have to explicitly tell Jsonify to add it to the builder.

Let's say that the partial file, `_my_partial.jsonify`, is as follows:

    json << 3
    json << 4

This `json` variable in this partial is a separate distinct `Jsonify::Builder` instance from the `json` variable in the main template.

> Note: Figure out if a the `json` instance can be passed to the Jsonify partial.
> It would make things easier and we wouldn't have to ingest the result.

This partial results in the following string:

    "[3,4]"

The `ingest!` method will actually parse this string back into a Jsonify-based object, and adds it to the builder's current state. The resulting output will be:

    "[1,[3,4]]"

##### Other partials

You can also use output from non-Jsonify templates (e.g. erb); just remember that the output from a template is always a string and that you have to tell the builder how to include the result of the partial.

For example, suppose you have the partial `_today.erb` with the following content:

    <%= Date.today %>

You can then incorporate this partial into your Jsonify template just as you would any other string value:

    json << 1
    json << {:date => (render :partial => 'today')}

  renders ...
  
    [1,{"date":"2011-07-30"}]

### Tilt Integration

Jsonify includes support for [Tilt](http://github.com/rtomayko/tilt). This allow you to create views that use Jsonify with any framework that supports Tilt. Here's an example of a simple [Sinatra](http://sinatrarb.com) application that leverages Jsonify's Tilt integration.

    require 'bundler/setup'
    require 'sinatra'

    require 'jsonify'
    require 'jsonify/tilt'

    helpers do
      def jsonify(*args) render(:jsonify, *args) end
    end

    get '/' do
      jsonify :index
    end

And the corresponding template in `views\index.jsonify`

    json.hello :frank

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
to most developers. It's analogous to the nested element structure common
in XML. The [JSON RFC](http://www.ietf.org/rfc/rfc4627.txt) states that 
"the names within an object SHOULD be unique". Jsonify enforces this recommendation by backing the JsonObject with a `Hash`; an object must have unique keys and the last one in, wins.

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

    {
      "my location": "Library Coffeehouse",
      "neighborhood": "Brookhaven"
    }

Jsonify also supports a hash-style interface for creating JSON objects.

    json = Jsonify::Builder.new
    
    json[:foo] = :bar
    json[:go]  = :far
    
  compiles to ...

    {
      "foo": "bar",
      "go": "far"
    }

You can these hash-style methods within a block as well ...

    json.homer do
      json[:beer] = "Duffs"
      json[:spouse] = "Marge"
    end

  compiles to ...

    {
      "homer": {
        "beer": "Duffs",
        "spouse": "Marge"
      }
    }

If you prefer a more method-based approach, you can use the `store!` method passing it the key and value.

    json.store!(:foo, :bar)
    json.store!(:go, :far)

#### JSON Arrays

A JSON array is an ordered list of JSON values. A JSON value can be a simple value,
like a string or a number, or a supported JavaScript primitive like true, false, or null.
A JSON value can also be a JSON object or another JSON array. Jsonify strives to make
this kind of construction possible in a buider-style.

Jsonify supports JSON array construction through two approaches: `method_missing` and `append!`.

##### method_missing

Pass an array and a block to `method_missing` (or `tag!`), and Jsonify will create a JSON array. It will then iterate over your array and call the block for each item in the array. Within the block, you use the `json` object to add items to the JSON array.

That JSON array is then set as the value of the name-value pair, where the name comes from the method name (for `method_missing`)
or symbol (for `tag!`).

So this construct is really doing two things -- creating a JSON pair, and creating a JSON array as the value of the pair.

    Jsonify::Builder.pretty do |json|
      json.letters('a'..'c') do |letter|
        json << letter.upcase
      end
    end
    
results in ...

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

    json = Jsonify::Builder.new
    json.append! 'a'.upcase, 'b'.upcase, 'c'.upcase

    [
      "A",
      "B",
      "C"
    ]

or more idiomatically ...

    json.append! *('a'..'c').map(&:upcase)

The append ___operator___, `<<`, can be used to push a single value into the array:

    json << 'a'.upcase
    json << 'b'.upcase
    json << 'c'.upcase
    
Of course, standard iteration works here as well ...

    json = Jsonify::Builder.new
    ('a'..'c').each do |letter|
      json << letter.upcase
    end

#### Mixing JSON Arrays and Objects

You can readily mix JSON arrays and objects and the Jsonify builder will do
its best to keep things straight.

Here's an example where we start off with an array; but then decide to throw in an object.

    json = Jsonify::Builder.new
    json.append! 1,2,3
    json.say "go, cat go"

  compiles to ...

    [1,2,3,{"say":"go, cat go"}]

When Jsonify detected that you were trying to add a JSON name-value pair to a JSON array, it converted that pair to a JSON object.

Let's take a look at the inverse approach ... say, we are creating a JSON object; and then decide to add an array item ...

    json.foo 'bar'
    json.go  'far'
    json  << 'baz'

In this case, Jsonify decides from the first line that you are creating a JSON object. When it gets to the third line, it simply turns the single item ('baz') into a name-value pair with a `null` value:

    {"foo":"bar","go":"far","baz":null}

## Documentation

[Yard Docs](http://rubydoc.info/github/bsiggelkow/jsonify/master/frames)

<a name='related'/>
<h2>Related Projects</h2>
- [Argonaut](https://github.com/jbr/argonaut)
- [JSON Builder](https://github.com/dewski/json_builder)
- [RABL](https://github.com/nesquena/rabl)
- [Representative](https://github.com/mdub/representative)
- [Tokamak](https://github.com/abril/tokamak)

## License

This project is released under the MIT license.

## Authors

* [Bill Siggelkow](https://github.com/bsiggelkow)
