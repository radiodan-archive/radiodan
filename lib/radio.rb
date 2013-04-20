require 'eventmachine'
require 'em-synchrony'

$: << './lib'

require 'em_additions'
require 'radio/logging'
require 'radio/builder'

class Radio
  include Logging
  attr_reader :builder
  
  def initialize(&blk)
    @builder = Builder.new(&blk)
  end
  
  def start
    # keep player running on schedule
    raise "no player set" unless player.adapter?
    
    EM.synchrony do
      trap_signals!
      
      EM.next_tick do      
        builder.call_middleware!
      end

      EM.now_and_every(seconds: 1) do
        logger.info "SYNC!"
        player.sync if player
      end
    end
  end
  
  def stop
    logger.info "Shutting down"
    player.stop if player
  end
  
  private
  def player
    builder.player
  end
  
  def trap_signals!
    %w{INT TERM SIGHUP SIGINT SIGTERM}.each do |signal|
      Signal.trap(signal) do
        logger.info "Trapped #{signal}"
        EM::Synchrony.next_tick do
          begin
            stop
          ensure
            EM.stop
          end
        end
      end
    end
  end
end
