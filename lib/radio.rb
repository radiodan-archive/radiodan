require 'em_additions'

module Radio
  def self.new(&blk)
    EM.synchrony do
      @radio = Control.new(&blk)
      
      %w{INT TERM SIGHUP SIGINT SIGTERM}.each do |signal|
        Signal.trap(signal) do
          puts "Trapped #{signal}"
          EM::Synchrony.next_tick do
            begin
              @radio.stop
            ensure
              EM.stop
            end
          end
        end
      end
    end
  end
end

%w{panic download logging control mpd state stimulus content}.each do |file|
  require_relative "./radio/#{file}"
end
