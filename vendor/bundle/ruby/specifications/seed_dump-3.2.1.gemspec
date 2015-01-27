# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "seed_dump"
  s.version = "3.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Rob Halff", "Ryan Oblak"]
  s.date = "2014-12-15"
  s.description = "Dump (parts) of your database to db/seeds.rb to get a headstart creating a meaningful seeds.rb file"
  s.email = "rroblak@gmail.com"
  s.extra_rdoc_files = ["README.md"]
  s.files = ["README.md"]
  s.homepage = "https://github.com/rroblak/seed_dump"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "{Seed Dumper for Rails}"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, ["~> 4"])
      s.add_runtime_dependency(%q<activerecord>, ["~> 4"])
      s.add_development_dependency(%q<byebug>, ["~> 2.0"])
      s.add_development_dependency(%q<factory_girl>, ["~> 4.0"])
      s.add_development_dependency(%q<activerecord-import>, ["~> 0.4"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0"])
    else
      s.add_dependency(%q<activesupport>, ["~> 4"])
      s.add_dependency(%q<activerecord>, ["~> 4"])
      s.add_dependency(%q<byebug>, ["~> 2.0"])
      s.add_dependency(%q<factory_girl>, ["~> 4.0"])
      s.add_dependency(%q<activerecord-import>, ["~> 0.4"])
      s.add_dependency(%q<jeweler>, ["~> 2.0"])
    end
  else
    s.add_dependency(%q<activesupport>, ["~> 4"])
    s.add_dependency(%q<activerecord>, ["~> 4"])
    s.add_dependency(%q<byebug>, ["~> 2.0"])
    s.add_dependency(%q<factory_girl>, ["~> 4.0"])
    s.add_dependency(%q<activerecord-import>, ["~> 0.4"])
    s.add_dependency(%q<jeweler>, ["~> 2.0"])
  end
end
