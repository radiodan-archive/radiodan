require 'thin'
require 'sinatra/base'
require 'faye'

class WebApp < Sinatra::Base
  use Faye::RackAdapter, :mount => '/faye', :timeout => 25
  
  get '/' do
    "HELLO\n"
  end
end
