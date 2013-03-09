require 'eventmachine'
require 'em-synchrony'

require_relative '../em_additions'

class Radio::Control
  attr_accessor :config
  
  def initialize(config=nil)
    @config = config || YAML.load_file(File.join(ROOT, 'config.yml'))
    @playlists = Radio::Playlist.new(path: File.join(ROOT, 'playlists'))

    @mpd = Radio::MPD.new(@config)
    @mpd.playlists = @playlists

    # download BBC Radio playlists
    # Querystrings suggest each stream valid for 4 hours
    # dump this info into db,
    # so we don't have to run on every boot
    EM.now_and_every(hours: 3.9) do
      @playlists.download
    end

    @file_control = Radio::Stimulus::File.new(@mpd)

    EM.now_and_every(seconds: 0.5) do
      @file_control.check
    end
  end
  
  def start
    # keep MPD running on schedule
    EM.now_and_every(seconds: 1) do
      @mpd.sync if @mpd
    end
  end
  
  def stop
    Radio::Logger.info "Shutting down"
    @mpd.stop if @mpd
  end
end
