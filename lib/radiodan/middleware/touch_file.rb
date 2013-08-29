=begin
Controls the radio by touching files.

This class looks for matching files in 
a given directory. When the file exists,
the corresponding event is triggered and
the file deleted.
=end

class Radiodan
class TouchFile
  include Logging  
  def initialize(config)
    @path = config[:dir]
  end

  def call(player)
    EM::Synchrony.now_and_every(0.5) do
      player.events.each do |event|
        file = event.to_s
        p = Pathname.new(File.join(@path, file))
        if p.exist?
          logger.debug "Responding to file #{file}"
          p.delete
          player.trigger_event file
        end
      end
    end
  end
end
end
