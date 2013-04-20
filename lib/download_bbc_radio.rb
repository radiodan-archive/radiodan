=begin
In order to fake a radio, we need to stream radio content.
BBC Radio streams are playlist files, which contain
a link to a time-restricted audio stream.

Every few hours, the stream disconnects and you have to 
download the playlist again to continue.

This class downloads the playlists, 
parses for the audio end point and
places it in MPD's playlist directory.
=end

require "em-synchrony/em-http"

class DownloadBBCRadio
  URL = "http://www.bbc.co.uk/radio/listen/live/r%s_aaclca.pls"
  STATIONS = %w{1 1x 2 3 4 4lw 4x 5l 5lsp 6}
  attr_accessor :stations

  def run
    @stations ||= Hash.new
    
    STATIONS.each do |station|
      req = EM::HttpRequest.new(URL % station).get
      next if req.response_header.status != 200

      url = req.response.match(/^File1=(.*)$/)[1]

      station_name = "bbc_radio_#{station}"

      content = Radio::Content.new 'playlist', station, Array(url)
      @stations[station_name] = content
    end
  end
end
