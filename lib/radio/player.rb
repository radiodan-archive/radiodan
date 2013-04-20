module Radio
class Player
  include Logging
  attr_reader :adapter, :state, :events
  
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
      raise "Event #{event} triggered but not found" 
    end
    
    event_bindings.each do |blk|
      blk.call(data)
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
