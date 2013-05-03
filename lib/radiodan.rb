require 'eventmachine'
require 'em-synchrony'

$: << './lib/radiodan'

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
    
    EM.synchrony do
      trap_signals!
      
      EM.next_tick do      
        @builder.call_middleware!
      end

      EM.now_and_every(seconds: 1) do
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

