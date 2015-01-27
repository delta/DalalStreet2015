# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "hiredis"
  s.version = "0.5.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pieter Noordhuis"]
  s.date = "2014-04-10"
  s.description = "Ruby wrapper for hiredis (protocol serialization/deserialization and blocking I/O)"
  s.email = ["pcnoordhuis@gmail.com"]
  s.extensions = ["ext/hiredis_ext/extconf.rb"]
  s.files = ["ext/hiredis_ext/extconf.rb"]
  s.homepage = "http://github.com/redis/hiredis-rb"
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "Ruby wrapper for hiredis (protocol serialization/deserialization and blocking I/O)"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, ["= 10.0"])
      s.add_development_dependency(%q<rake-compiler>, ["~> 0.7.1"])
    else
      s.add_dependency(%q<rake>, ["= 10.0"])
      s.add_dependency(%q<rake-compiler>, ["~> 0.7.1"])
    end
  else
    s.add_dependency(%q<rake>, ["= 10.0"])
    s.add_dependency(%q<rake-compiler>, ["~> 0.7.1"])
  end
end
