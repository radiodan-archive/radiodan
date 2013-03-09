=begin
  Controls the radio by touching files.
  
  This class looks for matching files in 
  a given directory. When the file exists,
  the corresponding command is called and
  the file deleted.
=end

class Radio::Stimulus::File
  PATH  = File.join(ROOT, 'tmp')
  FILES = %w{stop play pause panic}
  
  def initialize(options)
    @player = options[:player]
    @state  = options[:state]
  end
  
  def check
    FILES.each do |file|
      p = Pathname.new(File.join(PATH, file))
      if p.exist?
        Radio::Logger.debug "Responding to file #{file}"
        p.delete
        
        if file == 'panic'
          @state.panic!
        else
          @mpd.send file
        end
      end
    end
  end
end
