require 'eventmachine'
require 'em-synchrony'

require 'active_support'
require 'active_support/core_ext/string'

require_relative '../em_additions'

module Radio
class Control
  include Logging
  attr_reader :player, :middlewares
    
  def initialize(&blk)
    @middlewares = []
    
    yield(self)
    
    raise "no player set" if @player.nil?
    
    @middlewares.each{ |m| m.call(@player) }
  end

  def use(klass, *config)
    @middlewares << register(klass, *config)
  end
  
  def player(klass, *config)
    @player = register(klass, *config)
  end
  
  def state(options)
    @player.state = State.new(options) if @player
  end

  def start
    # keep player running on schedule
    EM.now_and_every(seconds: 1) do
      @player.sync if @player
    end
  end
  
  def stop
    logger.info "Shutting down"
    @player.stop if @player
  end
  
  private
  def register(klass, *config)
    radio_klass = Radio.const_get(klass.to_s.classify)

    if config.empty?
      radio_klass.new
    else
      radio_klass.new(*config)
    end
  end
end
end
