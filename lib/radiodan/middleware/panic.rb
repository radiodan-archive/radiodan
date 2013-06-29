class Radiodan
class Panic
  include Logging
  
  def initialize(config)
    @panic      = false
    @timeout    = config.delete(:duration).to_i
    @playlist   = config[:playlist]
  end
  
  def call(player)
    @player = player
    
    @player.register_event :panic do
      panic!
    end
  end
  
  def panic?
    @panic == true
  end

  def panic!
    return true if panic?
    
    @panic = true
    
    original_state = @player.playlist
  
    Thread.new do
      logger.debug "panic for #{@timeout} seconds"
      @player.playlist = @playlist
      sleep(@timeout)
      return_to_state original_state
    end
  
    @panic
  end

  def return_to_state(playlist)
    logger.debug "calming"
    @panic = false
    @player.playlist = playlist
  end
end
end
