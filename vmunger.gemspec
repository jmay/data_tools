# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'vmunger/version'

Gem::Specification.new do |s|
  s.name        = "vmunger"
  s.version     = VMunger::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors = ["Jason May"]
  s.email = %q{jmay@pobox.com}
  s.homepage    = "http://rubygems.org/gems/vmunger"
  s.summary = %q{Data-munging utilities for Veriphyr.}
  s.description = %q{Data-munging utilities for Veriphyr, including extensions to Array, Hash, String, Symbol plus data conversions and transformations.}

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "vmunger"

  s.add_development_dependency "bundler", ">= 1.0.0.rc.5"
  s.add_dependency('ap')
  s.add_dependency('facets')

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").select{|f| f =~ /^bin/}
  s.require_path = 'lib'
end
