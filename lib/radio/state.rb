=begin
  The State object determines what the player
  should be doing at any given moment.
  
  Attributes:
    playback: boolean
    content: content object to be playing
  
  It can be updated by any of the stimulus objects.
=end

require 'radio/content'

class Radio
class State
  include Logging
  attr_reader :playback, :content

  def initialize(config={})
    @playback = config[:playback] || 'play'
    @playlist = config[:playlist]
    set_state
  end

  private
  def set_state    
    @content  = Radio::Content.find_playlist(@playlist)
    
    unless @content
      if @playback == 'stopped'
        @content = Radio::Content.new
      else
        logger.error "Cannot find playlist #{@playlist}"
      end
    end
    
    logger.debug self
  end
end
end
