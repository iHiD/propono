# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'propono/version'

Gem::Specification.new do |spec|
  spec.name          = "propono"
  spec.version       = Propono::VERSION
  spec.authors       = ["MalcyL", "iHiD"]
  spec.email         = ["malcolm@landonsonline.me.uk", "jeremy@meducation.net"]
  spec.description   = %q{Pub / Sub Library using Amazon Web Services}
  spec.summary       = %q{General purpose pub/sub library built on top of AWS SNS and SQS}
  spec.homepage      = ""
  spec.license       = "AGPL3"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "fog", "~> 1.15.0"
  spec.add_dependency "thread", "~> 0.1.1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "minitest", "~> 5.0.8"
end
