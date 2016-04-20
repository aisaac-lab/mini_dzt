# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mini_dzt/version'

Gem::Specification.new do |spec|
  spec.name          = "mini_dzt"
  spec.version       = MiniDzt::VERSION
  spec.authors       = ["gogotanaka"]
  spec.email         = ["mail@tanakakazuki.com"]

  spec.summary       = %q{Slice deep-zoom images.}
  spec.description   = %q{This gem is inspireed by https://github.com/dblock/dzt}
  spec.homepage      = "https://github.com/aisaac-lab/mini_dzt"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.add_dependency 'gli'
  spec.add_dependency 'mini_magick'
end
