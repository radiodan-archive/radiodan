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
  def_delegators :adapter, :stop
  
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
    # run sync to explicitly conform to new playlist?
    
    @playlist
  end
  
=begin
  Sync checks the current status of the player.
  Is it paused? Playing? What is it playing?
  It compares the expected to actual statuses and
  makes changes required to keep them the same.
=end
  def sync
    return false unless adapter?

    current  = adapter.playlist
    expected = playlist

    state = Radiodan::PlaylistSync.new expected, current

    if state.sync?
      true
    else
      # playback state
      if state.errors.include? :state
        logger.debug "Expected: #{expected.state} Got: #{current.state}"
        trigger_event :play_state, expected.state
      end
      
      if state.errors.include? :mode
        logger.debug "Expected: #{expected.mode} Got: #{current.mode}"
        trigger_event :play_mode, expected.mode
      end
      
      # playlist
      if state.errors.include? :playlist
        logger.debug "Expected: #{expected.current} Got: #{current.current}"
        trigger_event :playlist, expected
      end
      
      false
    end
  end
end
end
