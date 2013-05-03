# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'radiodan/version'

EM_VERSION = '~> 1.0.3'

Gem::Specification.new do |gem|
  gem.name          = "radiodan"
  gem.version       = Radiodan::VERSION
  gem.authors       = ["Dan Nuttall"]
  gem.email         = ["pixelblend@gmail.com"]
  gem.description   = %q{Web-enabled radio that plays to my schedule.}
  gem.summary       = %q{Web-enabled radio that plays to my schedule.}
  gem.homepage      = "https://github.com/pixelblend/radiodan"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency 'eventmachine',     EM_VERSION
  gem.add_dependency 'em-synchrony',     EM_VERSION
  gem.add_dependency 'em-http-request',  EM_VERSION
  gem.add_dependency 'em-simple_telnet', '~> 0.0.6'
  gem.add_dependency 'active_support',   '~> 3.0.0'
end
