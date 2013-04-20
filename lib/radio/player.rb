require 'radio/event_binding'

class Radio
class Player
  include Logging
  include EventBinding
  
  attr_reader :adapter, :state
  
  def initialize
    @state = State.new(:playback => 'stopped')
  end
  
  def adapter=(adapter)
    @adapter = adapter
    @adapter.player = self
  end
  
  def adapter?
    !adapter.nil?
  end
  
  def state=(new_state)
    @state = new_state
    trigger_event(:state, @state)
    
    @state
  end
  
=begin
  Sync checks the current status of the player.
  Is it paused? Playing? What is it playing?
  It compares the expected to actual statuses and
  makes changes required to keep them the same.
=end
  def sync
    current_state  = adapter.state
    expected_state = state

    # playlist
    unless expected_state.content.files.include?(current_state.file)
      logger.debug "Expected: #{expected_state.content.files.first} Got: #{current_state.file}"
      trigger_event :playlist, expected_state.content
    end

    # playback state
    unless expected_state.playback == current_state.state
      logger.debug "Expected: #{expected_state.playback} Got: #{current_state.state}"
      trigger_event expected_state.playback
    end
  end
end
end
