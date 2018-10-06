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

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = Dir['bin/*'] + Dir['lib/**/*']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'thor'
  spec.add_dependency 'rest-client'
  spec.add_dependency 'rainbow'
  spec.add_dependency 'highline'
  spec.add_dependency 'filesize'

  spec.add_development_dependency "bundler", '~> 1.13', '>= 1.13.7'
  spec.add_development_dependency "rake", '~> 12.0', '>= 12.0.0'
end
