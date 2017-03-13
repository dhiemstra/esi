# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'esi/version'

Gem::Specification.new do |spec|
  spec.name          = "esi"
  spec.version       = Esi::VERSION
  spec.authors       = ["Danny Hiemstra"]
  spec.email         = ["dannyhiemstra@gmail.com"]

  spec.summary       = "EVE ESI API wrapper"
  spec.description   = "EVE ESI API wrapper"
  spec.homepage      = "https://github.com/dhiemstra/esi"
  spec.license       = "MIT"

  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "http://mygemserver.com"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = %w(.document CONTRIBUTING.md LICENSE.md README.md oauth2.gemspec) + Dir['lib/**/*.rb']
  spec.require_paths = ["lib"]

  spec.add_dependency "oauth2", "~> 1.2"
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
