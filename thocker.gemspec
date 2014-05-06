# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'thocker/version'

Gem::Specification.new do |spec|
  spec.name          = "thocker"
  spec.version       = Thocker::VERSION
  spec.authors       = ['Russell Teabeault', 'Jonathan Chauncey', 'Matt Farrar']
  spec.email         = ["thefellowship@rallydev.com"]
  spec.summary       = %q{Docker development gem}
  spec.description   = %q{Docker development gem}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_dependency 'thor'
  spec.add_dependency 'thor-scmversion'
  spec.add_dependency 'serverspec'
  spec.add_dependency 'docker-api'
  spec.add_dependency 'rspec'
  spec.add_dependency 'mixlib-shellout'
  spec.add_dependency 'buff-config'
end
