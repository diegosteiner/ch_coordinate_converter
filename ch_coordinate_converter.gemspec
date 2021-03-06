# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ch_coordinate_converter/version'

Gem::Specification.new do |spec|
  spec.name          = "ch_coordinate_converter"
  spec.version       = ChCoordinateConverter::VERSION
  spec.authors       = ["Diego P. Steiner"]
  spec.email         = ["diego.steiner@u041.ch"]
  spec.description   = "Converts coordinates between wgs84 and lv03"
  spec.summary       = "Converts coordinates between wgs84 and lv03"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
