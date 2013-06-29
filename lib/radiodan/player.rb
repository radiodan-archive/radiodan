require 'logging'
require 'event_binding'
require 'state_sync'

class Radiodan
class Player
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

    current_state  = adapter.state
    expected_state = playlist

    state = Radiodan::StateSync.new expected_state, current_state
    
    if state.sync?
      true
    else
      # playback state
      # this should only run when a new playlist is set??
      if state.errors.include? :state
        logger.debug "Expected: #{expected_state.state} Got: #{current_state.state}"
        trigger_event :play_state, expected_state.state
      end
      
      if state.errors.include? :mode
        logger.debug "Expected: #{expected_state.mode} Got: #{current_state.mode}"
        trigger_event :play_mode, expected_state.mode
      end
      
      # playlist
      if state.errors.include? :playlist
        logger.debug "Expected: #{expected_state.current} Got: #{current_state.file}"
        trigger_event :playlist, expected_state
      end
      
      false
    end
  end
end
end
