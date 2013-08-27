class Radiodan
module EventBinding
  def register_event(event, &blk)
    logger.info "Registered event #{event}"
    event = event.to_sym
    event_bindings[event] << blk
    
    true
  end
  
  def trigger_event(event, data=nil)
    event = event.to_sym
    bindings = event_bindings[event]
    
    unless bindings
      logger.error "Event #{event} triggered but not found" 
    end
    
    # also, run the events bound to :all, no matter the event
    bindings += event_bindings[:all]
    
    bindings.each do |blk|
      EM::Synchrony.next_tick { blk.call(data) }
    end
  end
  
  def events
    event_bindings.keys.sort
  end
  
  def respond_to?(method)
    if event_bindings.include?(method)
      true
    else
      super
    end
  end
  
  private
  def event_bindings
    @event_bindings ||= Hash.new{ |h, k| h[k] = [] }
  end
  
  def method_missing(method, *args, &block)
    if event_bindings.include?(method)
      trigger_event(method, *args)
    else
      super
    end
  end  
end
end
