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

module Radio
class State
  include Logging
  attr_reader :playback, :content, :timeout, :panic

  def initialize(config={})
    @config = config
    @panic  = false
    set_state
  end

  def stop
    @playback = "stop"
  end

  def play
    @playback = "play"
  end
  
  def panic?
    @panic == true
  end

  def panic!
    @panic = true
    set_state
  
    Thread.new do
      logger.debug "panic for #{@timeout} seconds"
      sleep(@timeout)
      calm!
    end
  
    @panic
  end

  def calm!
    @panic = false
    set_state
  end

  private
  def set_state
    state = panic? ? @config[:panic] : @config
  
    @playback = state[:playback]
    @content  = Radio::Content.find_playlist(state[:playlist])
    
    unless @content
      err = "Cannot find playlist #{state[:playlist]}"
      logger.error err
      raise err
    end
    
    @timeout  = state[:duration].to_i
  
    logger.debug self
  end
end
end