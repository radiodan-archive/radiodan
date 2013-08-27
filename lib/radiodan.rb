require 'eventmachine'
require 'em-synchrony'

$: << File.dirname(__FILE__)+'/radiodan/'

require 'em_additions'
require 'logging'
require 'builder'
require 'version'

class Radiodan
  include Logging

  def initialize(&blk)
    @builder = Builder.new(&blk)
  end
  
  def start
    # keep player running on schedule
    raise "no player set" unless player.adapter?
    
    stop_player_on_exit
    
    EM.synchrony do
      trap_signals!
      EventMachine::Synchrony.next_tick { @builder.call_middleware! }
      
      EM::Synchrony.add_periodic_timer(1) do
        logger.info "SYNC!"
        player.sync if player
      end
    end
  end

  def player
    @builder.player
  end
  
  def respond_to?(method)
    if player.respond_to? method
      true
    else
      super
    end
  end

  private
  
  def method_missing(method, *args, &block)
    if player.respond_to? method
      player.send method, *args, &block
    else
      super
    end
  end
  
  def stop_player_on_exit
    at_exit do
      logger.info 'Stopping player'
      stop
    end
  end
  
  def trap_signals!
    %w{INT TERM SIGHUP SIGINT SIGTERM}.each do |signal|
      Signal.trap(signal) do
        logger.info "Trapped #{signal}"
        EM.stop
      end
    end
  end
end

