class Radiodan
class Panic
  include Logging
  
  def initialize(config)
    @panic      = false
    @timeout    = config.delete(:duration).to_i
    @state      = State.new(config)
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
    
    original_state = @player.state
  
    Thread.new do
      logger.debug "panic for #{@timeout} seconds"
      @player.state = @state
      sleep(@timeout)
      return_to_state original_state
    end
  
    @panic
  end

  def return_to_state(state)
    logger.debug "calming"
    @panic = false
    @player.state = state
  end
end
end
