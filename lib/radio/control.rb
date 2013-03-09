require 'eventmachine'
require 'em-synchrony'

require_relative '../em_additions'

module Radio
class Control
  include Logging
  attr_accessor :config
  
  def initialize(config)
    @config = config
    @playlists = Radio::Playlist.new(path: config[:path][:playlist])

    @state = Radio::State.new(@config[:status])
    @player = Radio::MPD.new(@config)
    @player.state = @state

    # download BBC Radio playlists
    # Querystrings suggest each stream valid for 4 hours
    # dump this info into db,
    # so we don't have to run on every boot
    EM.now_and_every(hours: 3.9) do
      @playlists.download
    end

    @file_control = Radio::Stimulus::File.new(player: @player, state: @state)

    EM.now_and_every(seconds: 0.5) do
      @file_control.check
    end
  end
  
  def start
    # keep player running on schedule
    EM.now_and_every(seconds: 1) do
      @player.sync if @player
    end
  end
  
  def stop
    logger.info "Shutting down"
    @player.stop if @player
  end
end
end
