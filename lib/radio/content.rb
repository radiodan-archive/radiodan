=begin
  The Content object defines the source of audio
  for the player.
  
  We cant return the name of a playlist from mpd: we might as well build it up
  in memory.
  
  Attributes:
    type: playlist, a URL, or a single file
    location: URI for the content
    mode: sequential, random, resume
    song_number: song to resume play
    play_from: position to resume from (seconds)
=end

class Radio
class Content < Struct.new(:type, :name, :files, :mode, :song_number, :play_from)
  private
  def method_missing(method, *args, &block)
    if files.respond_to?(method)
      files.send(method, *args, &block)
    else
      super
    end
  end
end
end
