# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'casteml/version'

Gem::Specification.new do |spec|
  spec.name          = "casteml"
  spec.version       = Casteml::VERSION
  spec.authors       = ["Yusuke Yachi"]
  spec.email         = ["yyachi@misasa.okayama-u.ac.jp"]
  spec.summary       = %q{A Gem for CASTEML.}
  spec.description   = %q{This is a gem for CASTEML.}
  spec.homepage      = "http://devel.misasa.okayama-u.ac.jp/gitlab/gems/casteml"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.add_runtime_dependency 'medusa_rest_client', '~> 0.0.14'
  spec.add_runtime_dependency 'alchemist', '~> 0.1.7'
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 10.1.0"
  spec.add_development_dependency "rspec", "~> 3.0.0"
  spec.add_development_dependency "geminabox", "~> 0.12.4"
  spec.add_development_dependency "simplecov-rcov", "~> 0.2.3"
  spec.add_development_dependency "rspec_junit_formatter", "~> 0.2.0"
  #spec.add_development_dependency "ci_reporter_rspec", "~> 1.0.0"
  #spec.add_development_dependency "ci_reporter", "~> 2.0.0"

end
