# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "em-synchrony"
  s.version = "1.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ilya Grigorik"]
  s.date = "2013-01-21"
  s.description = "Fiber aware EventMachine libraries"
  s.email = ["ilya@igvita.com"]
  s.homepage = "http://github.com/igrigorik/em-synchrony"
  s.require_paths = ["lib"]
  s.rubyforge_project = "em-synchrony"
  s.rubygems_version = "2.0.3"
  s.summary = "Fiber aware EventMachine libraries"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<eventmachine>, [">= 1.0.0.beta.1"])
    else
      s.add_dependency(%q<eventmachine>, [">= 1.0.0.beta.1"])
    end
  else
    s.add_dependency(%q<eventmachine>, [">= 1.0.0.beta.1"])
  end
end
