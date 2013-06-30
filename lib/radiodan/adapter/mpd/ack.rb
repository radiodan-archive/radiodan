class Radiodan::MPD
  class Ack
    FORMAT = /ACK \[(\d)+@(\d)+\] \{(.*)\} (.*)/
    attr_reader :error_id, :position, :command, :description
    
    def initialize(ack)
      matches = FORMAT.match(ack)
      @error_id, @position, @command, @description = *matches[1..-1]
    end
  end
end
