# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'esi/version'

Gem::Specification.new do |spec|
  spec.name          = 'esi'
  spec.version       = Esi::VERSION
  spec.authors       = ['Danny Hiemstra']
  spec.email         = ['dannyhiemstra@gmail.com']

  spec.summary       = 'EVE ESI API wrapper'
  spec.description   = 'EVE ESI API wrapper'
  spec.homepage      = 'https://github.com/dhiemstra/esi'
  spec.license       = 'MIT'

  spec.files         = %w(LICENSE.txt README.md esi.gemspec) + Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'addressable', '~> 2.3'
  spec.add_dependency 'oauth2', '~> 1.4'
  spec.add_dependency 'recursive-open-struct', '~> 1'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '~> 0.52'
  spec.add_development_dependency 'shoulda', '~> 3.5'
end
