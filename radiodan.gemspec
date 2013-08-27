# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'radiodan/version'

EM_VERSION = '~> 1.0.3'

Gem::Specification.new do |gem|
  gem.name          = 'radiodan'
  gem.version       = Radiodan::VERSION
  gem.authors       = ['Dan Nuttall']
  gem.email         = ['pixelblend@gmail.com']
  gem.description   = %q{Web-enabled radio that plays to my schedule.}
  gem.summary       = %q{Web-enabled radio that plays to my schedule.}
  gem.homepage      = 'https://github.com/pixelblend/radiodan'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
  gem.add_development_dependency 'rake',        '~> 10.1.0'
  gem.add_development_dependency 'rspec',       '~> 2.13.0'
  gem.add_development_dependency 'guard-rspec', '~> 2.6.0'
  gem.add_development_dependency 'terminal-notifier-guard', '~> 1.5.0'
  gem.add_dependency 'eventmachine',     EM_VERSION
  gem.add_dependency 'em-synchrony',     EM_VERSION
  gem.add_dependency 'em-http-request',  EM_VERSION
  gem.add_dependency 'em-simple_telnet',  '~> 0.0.6'
  gem.add_dependency 'active_support',    '~> 3.0.0'
  gem.add_dependency 'i18n',              '~> 0.6.4'
  gem.add_dependency 'thin',              '~> 1.5.1'
  gem.add_dependency 'sinatra',           '~> 1.4.2'
  gem.add_dependency 'sinatra-synchrony', '~> 0.4.1'
end
