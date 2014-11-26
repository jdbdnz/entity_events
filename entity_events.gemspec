$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "entity_events/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "entity_events"
  s.version     = EntityEvents::VERSION
  s.authors     = ["Josh Dean"]
  s.email       = ["josh@chalkle.com"]
  s.homepage    = "http://rubygems.org/gems/entity_events"
  s.summary     = "Entity Events is a meta data collection tool"
  s.description = "In a nut shell, it records whenever one entity interacts with another entity. It also has more advanced features to allow specific event recording as well as ab testing"
  s.license     = "MIT"
  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2"

  s.add_development_dependency "sqlite3"
end
