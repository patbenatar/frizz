# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'frizz/version'

Gem::Specification.new do |spec|
  spec.name          = "frizz"
  spec.version       = Frizz::VERSION
  spec.authors       = ["patbenatar"]
  spec.email         = ["nick@gophilosophie.com"]
  spec.description   = "Utility for deploying static sites to S3"
  spec.summary       = "Utility for deploying static sites to S3"
  spec.homepage      = "http://github.com/patbenatar/frizz"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "s3", "~> 0.3.13"
  spec.add_dependency "colorize", "~> 0.6.0"
  spec.add_dependency "mime-types", "~> 1.25"
  spec.add_dependency "listen", "~> 1.2.2"
end
