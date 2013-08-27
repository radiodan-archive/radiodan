class Radiodan
class PlaylistToStart
  def initialize(*config)
    @playlist = config.shift
  end
  
  def call(player)
    player.playlist = @playlist
  end
end
end
