require 'forwardable'
require 'logging'
require 'event_binding'
require 'playlist_sync'

class Radiodan
class Player
  extend Forwardable
  include Logging
  include EventBinding
  
  attr_reader :adapter, :playlist
    
  def adapter=(adapter)
    @adapter = adapter
    @adapter.player = self
  end
  
  def adapter?
    !adapter.nil?
  end
  
  def playlist=(new_playlist)
    @playlist = new_playlist
    trigger_event(:playlist, @playlist)
    # trigger_event(:player_state, player_state)
    @playlist
  end
  
  def state
    adapter.playlist
  end
  
=begin
  Sync checks the current status of the player.
  Is it paused? Playing? What is it playing?
  It compares the expected to actual statuses and
  triggers events if there is a difference.
=end
  def sync
    return false unless adapter?

    current  = adapter.playlist
    expected = playlist

    sync = Radiodan::PlaylistSync.new expected, current

    if sync.sync?
      true
    else
      # playback state
      if sync.errors.include? :state
        logger.debug "Expected: #{expected.state} Got: #{current.state}"
        trigger_event :play_state, current.state
      end
      
      if sync.errors.include? :mode
        logger.debug "Expected: #{expected.mode} Got: #{current.mode}"
        trigger_event :play_mode, current.mode
      end
      
      # playlist
      if sync.errors.include? :playlist
        logger.debug "Expected: #{expected.current.inspect} Got: #{current.current.inspect}"
        trigger_event :playlist, expected
      end
      
      false
    end
  end

  def respond_to?(method)
    if adapter.respond_to? method
      true
    else
      super
    end
  end

  private
  
  def method_missing(method, *args, &block)
    if adapter.respond_to? method
      adapter.send method, *args, &block
    else
      super
    end
  end
end
end
