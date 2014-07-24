# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'prysless/version'

Gem::Specification.new do |spec|
  spec.name          = "prysless"
  spec.version       = Prysless::VERSION
  spec.authors       = ["yazgoo"]
  spec.email         = ["yazgoo@github.com"]
  spec.summary       = "a pry REPL to rule the all"
  spec.description   = spec.summary
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "pry"
  spec.add_runtime_dependency "pry-remote"
  spec.add_runtime_dependency "net-ssh"
end
