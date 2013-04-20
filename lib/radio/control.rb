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
    @player = Player.new
    
    yield(self)
  end

  def use(klass, *config)
    @middlewares << register(klass, *config)
  end
  
  def player(klass, *config)
    @player.adapter = register(klass, *config)
  end
  
  def state(options)
    @player.state = State.new(options) if @player
  end

  def start
    # keep player running on schedule
    raise "no player set" unless @player.adapter?
    
    EM.synchrony do
      EM.next_tick do      
        @middlewares.each{ |m| m.call(@player) }
      end

      EM.now_and_every(seconds: 1) do
        logger.info "SYNC!"
        @player.sync if @player
      end
      
      %w{INT TERM SIGHUP SIGINT SIGTERM}.each do |signal|
        Signal.trap(signal) do
          puts "Trapped #{signal}"
          EM::Synchrony.next_tick do
            begin
              @player.stop
            ensure
              EM.stop
            end
          end
        end
      end
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
