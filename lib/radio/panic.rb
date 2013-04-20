module Radio
class Panic
  attr_reader :panic, :state
  
  def initialize(config)
    @panic      = false
    @calm_state = nil
    @timeout    = config.delete(:duration).to_i
    @state      = State.new(config)
  end
  
  def call(player)
    @player = player
    # register panic event here
  end
  
  def panic?
    @panic == true
  end

  def panic!
    @panic = true
    #store old state
    @calm_state = @player.state
    
    player.state = @state
  
    Thread.new do
      logger.debug "panic for #{@timeout} seconds"
      sleep(@timeout)
      calm!
    end
  
    @panic
  end

  def calm!
    @panic = false
    
    if @calm_state
      player.state = @calm_state
      @calm_state = nil
    end
  end
end
end
