=begin
  Controls the radio by touching files.
  
  This class looks for matching files in 
  a given directory. When the file exists,
  the corresponding command is called and
  the file deleted.
=end

class Control::File
  PATH  = File.join(ROOT, 'tmp')
  FILES = %w{stop play pause}
  
  def initialize(mpd)
    @mpd = mpd
  end
  
  def check
    FILES.each do |file|
      p = Pathname.new(File.join(PATH, file))
      if p.exist?
        p.delete
        @mpd.send file
      end
    end
  end
end
