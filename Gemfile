source 'https://rubygems.org'

group :development do
  gem 'vagrant', '~> 1.0.0'
end

group :eventmachine do
  EM_VERSION = '~> 1.0.3'
  gem 'eventmachine',     EM_VERSION
  gem 'em-synchrony',     EM_VERSION
  gem 'em-http-request',  EM_VERSION
  gem 'em-simple_telnet', '~> 0.0.6'
end

group :database do
  DM_VERSION    = '~> 1.2.0'
  gem 'dm-sqlite-adapter',  DM_VERSION
  gem 'data_mapper',        DM_VERSION
end

group :web do
  gem 'faye',     '~> 0.8.9'
  gem 'thin',     '~> 1.5.0'
  gem 'sinatra',  '~> 1.3.5'
end

group :deploy do
  gem 'foreman',  '~> 0.62.0'
end

group :test do
  gem 'pry', '~> 0.9.12'
end

gem 'active_support'
