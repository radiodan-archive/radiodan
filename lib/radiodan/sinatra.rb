require 'sinatra/base'
require 'sinatra/synchrony'

class Radiodan::Sinatra < Sinatra::Base
  register Sinatra::Synchrony

  attr_reader :player

  def initialize(player)
    @player = player
    super()
  end
end
