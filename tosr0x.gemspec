# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tosr0x/version'

Gem::Specification.new do |spec|
  spec.name          = 'tosr0x'
  spec.version       = TOSR0x::VERSION
  spec.authors       = ['Filipe Alves']
  spec.email         = ['filipe.alves@bithium.com']

  # rubocop:disable Metrics/LineLength
  spec.summary       = %(This gem provides an API to the TOSR0x relay devices from http://www.tinyosshop.com)
  spec.description   = %(This gem provides an API to the TOSR0x relay devices from http://www.tinyosshop.com)
  spec.homepage      = 'https://github.com/bithium/tosr0x.git'
  # rubocop:enable Metrics/LineLength

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'serialport'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
