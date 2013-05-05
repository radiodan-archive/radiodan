require 'logging'
require 'event_binding'

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
    expected_state = state

    # playback state
    # this should only run when a new playlist is set??
    unless expected_state.playback == current_state.state
      logger.debug "Expected: #{expected_state.playback} Got: #{current_state.state}"
      trigger_event expected_state.playback
    end
    
    # playlist
    unless expected_state.content.files.include?(current_state.file)
      logger.debug "Expected: #{expected_state.content.files.first} Got: #{current_state.file}"
      trigger_event :playlist, expected_state.content
    end
  end
end
end
