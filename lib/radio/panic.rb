module Radio
class Panic
  include Logging
  
  def initialize(config)
    @panic      = false
    @calm_state = nil
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
    @panic = true
    #store old state
    @calm_state = @player.state
  
    Thread.new do
      logger.debug "panic for #{@timeout} seconds"
      @player.state = @state
      sleep(@timeout)
      calm!
    end
  
    @panic
  end

  def calm!
    logger.debug "calming"
    @panic = false
    
    if @calm_state
      logger.debug "setting calm state"
      @player.state = @calm_state
      @calm_state = nil
    end
  end
end
end
