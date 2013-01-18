module EventMachine
  def self.now_and_every(period, &blk)
    yield
  
    seconds = case
      when period.include?(:hours)
        period[:hours]*60*60
      when period.include?(:minutes)
        period[:minutes]*60
      else
        period[:seconds]
    end
  
    EM::Synchrony.add_periodic_timer(seconds) do
      yield
    end
  end
end