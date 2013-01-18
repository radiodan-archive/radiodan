require "em-synchrony"
require "em-synchrony/em-http"


class RadioPlaylist
  URL = "http://www.bbc.co.uk/radio/listen/live/r%s_aaclca.pls"
  STATIONS = %w{1 1x 2 3 4 4lw 4x 5l 5lsp 6}
  
  def initialize(options)
    @path = options[:path]
    @playlists = {}
  end
  
  def download
    STATIONS.each do |station|
      req = EM::HttpRequest.new(URL % station).aget
      req.callback do
        url = req.response.match(/^File1=(.*)$/)[1]
        
        if url != @playlists[station]
          @playlists[station] = url
          File.open("#{@path}/bbc_radio_#{station}.m3u", 'w'){ |f| f.write("#{url}\n") }
        end
      end
    end
  end
end
