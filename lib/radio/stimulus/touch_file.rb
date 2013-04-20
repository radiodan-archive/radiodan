=begin
Controls the radio by touching files.

This class looks for matching files in 
a given directory. When the file exists,
the corresponding command is called and
the file deleted.
=end

module Radio
class TouchFile
  include Radio::Logging
  FILES = %w{stop play pause panic}
  
  def initialize(config)
    @path = config[:dir]
  end

  def call(player)
    EM.now_and_every(seconds: 0.5) do
      FILES.each do |file|
        logger.debug "check for #{file}"
        p = Pathname.new(File.join(@path, file))
        if p.exist?
          logger.debug "Responding to file #{file}"
          p.delete
          player.send file
        end
      end
    end
  end
end
end
