# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wdmc/version'

Gem::Specification.new do |spec|
  spec.name          = "wdmc"
  spec.version       = Wdmc::VERSION
  spec.authors       = ["Ole Kleinschmidt"]
  spec.email         = ["ok@datenreisende.org"]
  spec.summary       = "Commandline for WD MyCloud NAS"
  spec.homepage      = "https://github.com/okleinschmidt/wdmc"
  spec.license       = "MIT"

  spec.files         = Dir['bin/*'] + Dir['lib/**/*']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'thor'
  spec.add_dependency 'rest-client'
  spec.add_dependency 'rainbow'
  spec.add_dependency 'highline'
  spec.add_dependency 'filesize'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
