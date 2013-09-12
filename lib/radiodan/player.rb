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
    trigger_event(:player_state, @adapter.playlist) if @adapter
    
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
    synced = sync.sync?

    unless synced
      # playback state
      sync.errors.each do |e|
        case e
        when :state
          logger.debug "Expected State: #{expected.state} Got: #{current.state}"
          trigger_event :play_state, current.state
        when :mode
          logger.debug "Expected Mode: #{expected.mode} Got: #{current.mode}"
          trigger_event :play_mode, current.mode
        when :new_tracks
          logger.debug "Expected: #{expected.current.inspect} Got: #{current.current.inspect}"
          trigger_event :playlist, expected
        when :add_tracks
          logger.debug "Found additional tracks to enqueue"
          trigger_event :enqueue, expected.tracks[current.tracks.size..-1]
          trigger_event :play_pending if sync.errors.include?(:state) && current.state == :stop
        when :volume
          logger.debug "Expected Volume: #{expected.volume} Got: #{current.volume}"
          trigger_event :volume, expected.volume
        end
      end
    end
    
    trigger_event :sync, current
    synced
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
