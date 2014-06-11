# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'abst_int/version'

Gem::Specification.new do |spec|
  spec.name          = "abst_int"
  spec.version       = AbstInt::VERSION
  spec.authors       = ["Yuutetu"]
  spec.email         = ["yuutetu@gmail.com"]
  spec.summary       = %q{Abstract Integer}
  spec.description   = %q{AbstInt provide abstract integer. This can be used to test exhaustively.}
  spec.homepage      = "https://github.com/yuutetu/abst_int"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-doc"
end
