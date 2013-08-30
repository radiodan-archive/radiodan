require 'rspec/autorun'
$:.unshift File.expand_path('../../lib/radiodan', __FILE__)

RSpec.configure do |config|
  #config.mock_with :mocha

  # Use color in STDOUT
  config.color_enabled = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # Use the specified formatter
  config.formatter = :documentation # :progress, :html, :textmate
end
