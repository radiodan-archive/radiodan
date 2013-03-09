=begin
  The Content object defines the source of audio
  for the player.
  
  This needs to be DB backed so we can list out playlists; m3u files are useless
  We cant return the name of a playlist from mpd: we might as well build it up
  in memory.
  
  Attributes:
    type: playlist, a URL, or a single file
    location: URI for the content
    mode: sequential, random, resume
    song_number: song to resume play
    play_from: position to resume from (seconds)
=end

module Radio
class Content < Struct.new(:type, :files, :mode, :song_number, :play_from)
  include Logging
  
  # stub method for now
  def self.find(playlist)
    logger.debug "Finding for #{playlist}"
    
    file = File.join(ROOT, 'playlists', "#{playlist}.m3u")
    url = IO.read(file).chomp rescue ''
    
    content = new('playlist', [url], 'sequential', 0, 0)
    
    # if it's a podcast, skip 30 seconds in
    if playlist == 'podcasts'
      content.mode = 'resume'
      content.play_from = 30
    end
    
    content
  end
  
  private
  def method_missing(method, *args, &block)
    if files.include?(method)
      files.send(method, *args, &block)
    else
      super
    end
  end
end
end
