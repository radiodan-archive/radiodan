class Radiodan
class TogglePlaylist
  include Logging
  
  def initialize(main_playlist, toggle_playlist)
    @playlists = [main_playlist, toggle_playlist]
  end
  
  def call(player)
    @player = player
    @player.playlist = @playlists.shift
    
    @player.register_event :toggle do
      logger.info "Toggling playlist"
      @player.playlist, @playlists = @playlists.shift, [@player.playlist]
    end
  end
end
end
