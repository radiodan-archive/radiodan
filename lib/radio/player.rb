class Radio
class Player
  include Logging
  attr_reader :adapter, :events
  
  def initialize
    @events = Hash.new{ |h, k| h[k] = [] }
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
  
  def state
    @state || State.new(:playback => 'stopped')
  end
  
  def register_event(event, &blk)
    logger.info "Registered event #{event}"
    event = event.to_sym
    @events[event] << blk
    
    true
  end
  
  def trigger_event(event, *data)
    event = event.to_sym
    event_bindings = events[event]
    
    unless event_bindings
      logger.error "Event #{event} triggered but not found" 
    end
    
    event_bindings.each do |blk|
      blk.call(data)
    end
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
      logger.debug 'update content'
      logger.debug "#{current_state.file} != #{expected_state.content.files.first}"
      adapter.playlist = expected_state.content
    end

    # playback state
    unless expected_state.playback == current_state.state
      logger.debug 'update playback'
      logger.debug "#{expected_state.playback} != #{current_state.state}"
      adapter.send expected_state.playback
    end
  end

  private
  def method_missing(method, *args, &block)
    if @events.include?(method)
      trigger_event(method, *args)
    else
      super
    end
  end
end
end
