# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jsonify/version"

Gem::Specification.new do |s|
  s.name        = "jsonify"
  s.version     = Jsonify::VERSION
  s.authors     = ["Bill Siggelkow"]
  s.email       = ["bsiggelkow@me.com"]
  s.homepage    = "http://github.com/bsiggelkow/jsonify"
  s.summary     = %q{Turn Ruby objects into JSON}
  s.description = %q{Turn Ruby objects into JSON -- correctly!}

  s.rubyforge_project = s.name

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,performance}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'multi_json', '~>1.3'
  
  s.add_development_dependency 'json' unless RUBY_VERSION =~ /^1.9/
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'tilt', '~>1.3.2'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'rdiscount'
end
