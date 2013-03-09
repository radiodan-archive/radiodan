require 'eventmachine'
require 'em-synchrony'

require_relative '../em_additions'

module Radio
class Control
  include Logging
  attr_accessor :config
  
  def initialize(config)
    @config = config

    @state = Radio::State.new(@config[:status])
    @player = Radio::MPD.new(@config)
    @player.state = @state

    @stimulus = Radio::Stimulus.new(player: @player, state: @state)
  end
  
  def start
    # keep player running on schedule
    EM.now_and_every(seconds: 1) do
      @player.sync if @player
      @stimulus.check
    end
  end
  
  def stop
    logger.info "Shutting down"
    @player.stop if @player
  end
end
end
