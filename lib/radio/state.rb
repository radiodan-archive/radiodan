=begin
  The State object determines what the player
  should be doing at any given moment.
  
  Attributes:
    playback: boolean
    content: content object to be playing
  
  It can be updated by any of the stimulus objects.
  
  It can be put into 'panic' mode, when the attributes change
  for a set amount of time (determined in config.yml)
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
      err = "Cannot find playlist #{@playlist}"
      logger.error err
      raise err
    end
    
    logger.debug self
  end
end
end
