=begin
  The Content object defines the source of audio
  for the player.
  
  We cant return the name of a playlist from mpd: we might as well build it up
  in memory.
  
  Attributes:
    type: playlist, a URL, or a single file
    location: URI for the content
    mode: sequential, random, resume
    song_number: song to resume play
    play_from: position to resume from (seconds)
=end

require 'data_mapper'

env = ENV['RACK_ENV'] || 'development'
db_file = File.join(File.dirname(__FILE__), '..', '..', 'db', "#{env}.sqlite3")
DataMapper.setup(:default, "sqlite://#{db_file}")

class Radio
class Content < Struct.new(:type, :files, :mode, :song_number, :play_from)
  include DataMapper::Resource

  property :id,           Serial
  property :name,         String,   required: true
  property :type,         String,   default:  'playlist'
  property :files,        Object,   default:  []
  property :mode,         String,   default:  'sequential'
  property :song_number,  Integer,  default:  0
  property :play_from,    Float,    default:  0.0
  property :created_at,   DateTime
  property :updated_at,   DateTime
  
  def self.find_playlist(playlist)
    first(type: 'playlist', :name => playlist)
  end
  
  def self.find_or_build_playlist(playlist)
    find_playlist(playlist) || new(type: 'playlist', :name => playlist)
  end
  
  private
  def method_missing(method, *args, &block)
    if files.include?(method)
      files.send(method, *args, &block)
    else
      super
    end
  end
end

Content.auto_upgrade!
Content.raise_on_save_failure = true
end
