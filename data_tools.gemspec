# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'data_tools/version'

Gem::Specification.new do |s|
  s.name        = "data_tools"
  s.version     = DataTools::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors = ["Jason May"]
  s.email = %q{jmay@pobox.com}
  s.homepage    = "http://github.com/jmay/data_tools"
  s.summary = %q{Miscellaneous data-munging utilities.}
  s.description = %q{Data-munging utilities, including extensions to Array, Hash, String, Symbol plus data conversions and transformations.}

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "data_tools"

  s.add_dependency('awesome_print', "~> 1.0")
  s.add_dependency('facets', ">= 2.9")

  s.add_development_dependency "rspec", "~> 2.7"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").select{|f| f =~ /^bin/}
  s.require_path = 'lib'
end
