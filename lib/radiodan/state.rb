=begin
  The State object determines what the player
  should be doing at any given moment.
  
  Attributes:
    playback: boolean
    content: content object to be playing
  
  It can be updated by any of the stimulus objects.
=end

require 'content'
require 'logging'

class Radiodan
class State
  include Logging
  attr_reader :playback, :content

  def initialize(config={})
    @playback = config[:playback] || 'stopped'
    @content  = config[:content]  || Content.new
  end
end
end
