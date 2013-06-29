require 'spec_helper'
require 'adapter/mpd/playlist_parser'

describe Radiodan::MPD::PlaylistParser do
  before :all do
    @attributes = { "volume"=>"57", "repeat"=>"1", "random"=>"1", "single"=>"0", "consume"=>"0", "playlist"=>"3", 
                    "playlistlength"=>"1", "xfade"=>"0", "mixrampdb"=>"0.000000", "mixrampdelay"=>"nan", "state"=>"pause", 
                    "song"=>"0", "songid"=>"2", "time"=>"0:0", "elapsed"=>"214.599", "bitrate"=>"0", "audio"=>"0:?:0" }
  end
  
  it 'creates matching playlist object' do
    playlist = subject.parse(@attributes, [file: '1'])
    
    playlist.state.should     == :pause
    playlist.mode.should      == :random
    playlist.repeat.should    == true
    playlist.tracks.should    == [file: '1']
    playlist.position.should  == 0
    playlist.seek.should      == 214.599
    playlist.volume.should    == 57
  end
end

