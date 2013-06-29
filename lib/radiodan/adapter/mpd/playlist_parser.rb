require 'playlist'

class Radiodan::MPD
module PlaylistParser
  def self.parse(attributes={}, playlist={})
    options           = parse_attributes(attributes)
    options[:content] = parse_playlist(playlist)
    
    Radiodan::Playlist.new(options)
  end

  private
  def self.parse_attributes(attributes)
    options = {}
    options[:state]     = attributes['state'].to_sym
    options[:mode]      = parse_mode(attributes)
    options[:repeat]    = attributes['repeat'] == '1'
    options[:position]  = attributes['song'].to_i
    options[:seek]      = attributes['elapsed'].to_f
    options[:volume]    = attributes['volume'].to_i
    
    options
  end

  def self.parse_mode(attributes)
    attributes['random'] == '1' ? :random : :sequential
  end
  
  def self.parse_playlist(playlist_hash)
    playlist_hash
  end
end
end
