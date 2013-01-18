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
