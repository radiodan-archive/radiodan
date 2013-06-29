class Radiodan::MPD
  class Ack
    FORMAT = /ACK \[(\d)+@(\d)+\] \{(.*)\} (.*)/
    attr_accessor :error_id, :position, :command, :description
    
    def intialize
      matches = FORMAT.match(ack)
      error_id, position, command, description = *matches[1..-1].join
    end
  end
end
