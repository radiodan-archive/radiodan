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

class Radio
class DownloadBBCRadio
  include Logging
  URL = "http://www.bbc.co.uk/radio/listen/live/r%s_aaclca.pls"
  STATIONS = %w{1 1x 2 3 4 4lw 4x 5l 5lsp 6}

  def run
    EM.now_and_every(hours: 3) do
      STATIONS.each do |station|
        req = EM::HttpRequest.new(URL % station).get
        next if req.response_header.status != 200

        url = req.response.match(/^File1=(.*)$/)[1]
        logger.debug "Downloading playlist for #{station}"

        station_name = "bbc_radio_#{station}"
        playlist = Content.find_or_build_playlist(station_name)

        if url != playlist.files.first
          playlist.files = Array(url)
          playlist.save
          logger.debug "saved #{station_name}"
        end
      end
    end
  end
end
end
