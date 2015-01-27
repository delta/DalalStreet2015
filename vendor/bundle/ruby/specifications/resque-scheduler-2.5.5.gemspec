# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "resque-scheduler"
  s.version = "2.5.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben VandenBos"]
  s.date = "2014-02-27"
  s.description = "Light weight job scheduling on top of Resque.\n    Adds methods enqueue_at/enqueue_in to schedule jobs in the future.\n    Also supports queueing jobs on a fixed, cron-like schedule."
  s.email = ["bvandenbos@gmail.com"]
  s.executables = ["resque-scheduler"]
  s.files = ["bin/resque-scheduler"]
  s.homepage = "http://github.com/resque/resque-scheduler"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "Light weight job scheduling on top of Resque"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<pry>, [">= 0"])
      s.add_development_dependency(%q<rack-test>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rubocop>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_runtime_dependency(%q<mono_logger>, ["~> 1.0"])
      s.add_runtime_dependency(%q<redis>, ["~> 3.0.4"])
      s.add_runtime_dependency(%q<resque>, ["~> 1.25.1"])
      s.add_runtime_dependency(%q<rufus-scheduler>, ["~> 2.0.24"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<pry>, [">= 0"])
      s.add_dependency(%q<rack-test>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rubocop>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<mono_logger>, ["~> 1.0"])
      s.add_dependency(%q<redis>, ["~> 3.0.4"])
      s.add_dependency(%q<resque>, ["~> 1.25.1"])
      s.add_dependency(%q<rufus-scheduler>, ["~> 2.0.24"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<pry>, [">= 0"])
    s.add_dependency(%q<rack-test>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rubocop>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<mono_logger>, ["~> 1.0"])
    s.add_dependency(%q<redis>, ["~> 3.0.4"])
    s.add_dependency(%q<resque>, ["~> 1.25.1"])
    s.add_dependency(%q<rufus-scheduler>, ["~> 2.0.24"])
  end
end
