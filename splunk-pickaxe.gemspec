# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'splunk/pickaxe/version'

Gem::Specification.new do |spec|
  spec.name          = 'splunk-pickaxe'
  spec.version       = Splunk::Pickaxe::VERSION
  spec.authors       = ['Bryan Baugher']
  spec.email         = ['bryan.baugher@Cerner.com']
  spec.licenses      = ['Apache-2.0']

  spec.summary       = 'A tool for syncing your repo of splunk objects with a splunk instance'
  spec.description   = 'A tool for syncing your repo of splunk objects with a splunk instance '
  spec.homepage      = 'http://github.com/Cerner/splunk-pickaxe'

  spec.files         = Dir['bin/*', 'lib/**/*.rb', 'Gemfile', 'Rakefile', 'README.md', 'project.yml']
  spec.executables   = spec.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'splunk-sdk-ruby', '~> 1.0'
  spec.add_runtime_dependency 'highline', '~> 1.7'
  spec.add_runtime_dependency 'thor', '~> 0.19'

  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
end
