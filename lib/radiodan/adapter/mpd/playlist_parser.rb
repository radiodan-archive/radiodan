require 'playlist'

class Radiodan
class MPD
module PlaylistParser
  def self.parse(attributes={}, tracks=[])
    options          = parse_attributes(attributes)
    options[:tracks] = parse_tracks(tracks)
    
    Playlist.new(options)
  end

  private
  def self.parse_attributes(attributes)
    options = {}
    
    begin
      options[:state]     = attributes['state'].to_sym
      options[:mode]      = parse_mode(attributes)
      options[:repeat]    = attributes['repeat'] == '1'
      options[:position]  = attributes['song'].to_i
      options[:seek]      = attributes['elapsed'].to_f
      options[:volume]    = attributes['volume'].to_i
    ensure
      return options
    end
  end
  
  def self.parse_tracks(tracks)
    if tracks.respond_to?(:collect)
      tracks.collect{ |t| Track.new(t) }
    else
      []
    end
  end

  def self.parse_mode(attributes)
    attributes['random'] == '1' ? :random : :sequential
  end
end
end
end
