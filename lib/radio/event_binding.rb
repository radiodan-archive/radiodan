class Radio  
module EventBinding
  def register_event(event, &blk)
    logger.info "Registered event #{event}"
    event = event.to_sym
    events[event] << blk
    
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
  
  private
  def events
    @events ||= Hash.new{ |h, k| h[k] = [] }
  end
end
end
