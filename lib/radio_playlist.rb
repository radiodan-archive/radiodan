=begin
  Radio Playlist
  --------------
    In order to face a radio, we need to stream audio content.
    The BBC radio streams as a playlist file, which contains
    a link to a time-restricted audio stream.
    
    Every few hours, the stream disconnects and you have to 
    download the playlist again to continue.

    This class downloads the playlists, parses the audio end point,
    and places it in MPD's playlist directory.
=end

require "em-synchrony/em-http"

class RadioPlaylist
  URL = "http://www.bbc.co.uk/radio/listen/live/r%s_aaclca.pls"
  STATIONS = %w{1 1x 2 3 4 4lw 4x 5l 5lsp 6}
  attr_reader :playlists
  
  def initialize(options)
    @path = options[:path]
    @playlists = {}
  end

  def [](station_name)
    @playlists[station_name]
  end

  def download
    print 'downloading...'
    STATIONS.each do |station|
      req = EM::HttpRequest.new(URL % station).get
      return false if req.response_header.status != 200
      
      url = req.response.match(/^File1=(.*)$/)[1]
      print " #{station}"
      
      station_name = "bbc_radio_#{station}"
      
      if url != @playlists[station_name]
        @playlists[station_name] = url
        File.open("#{@path}/#{station_name}.m3u", 'w'){ |f| f.write("#{url}\n") }
      end
    end
    puts '...doneloading'
  end
end
