require 'forwardable'

require_relative './mpd/connection'
require_relative './mpd/playlist_parser'

class Radiodan
class MPD
  class AckError < Exception; end
  include Logging
  extend  Forwardable
  
  def_delegators :@connection, :cmd

  COMMANDS = %w{stop pause clear play next previous enqueue search update}  
  SEARCH_SCOPE = %w{artist album title track name genre date composer performer comment disc filename any}
  attr_reader :player

  def initialize(options={})
    @connection = Connection.new(options)
    @connection.cmd('clear')
    @connection.cmd('update')
  end
  
  def player=(player)
    @player = player
    
    # register available player commands
    COMMANDS.each do |command|
      @player.register_event command do |data|
        if data
          self.send(command, data)
        else
          self.send(command)
        end
      end
    end
    
    # register new playlist events
    @player.register_event :playlist do |playlist|
      self.playlist = playlist
    end
    
    # register volume changes
    @player.register_event :volume do |volume|
      self.volume = volume
    end
  end

  def playlist=(playlist)
    # get rid of current playlist, stop playback
    clear
    
    # set random & repeat
    cmd(%Q{random #{boolean_to_s(playlist.random?)}})
    cmd(%Q{repeat #{boolean_to_s(playlist.repeat?)}})
    
    # set volume
    begin
      volume = playlist.volume
    rescue AckError => e
      logger.error e.msg
    end

    if playlist.empty?
      logger.error 'Playlist empty, nothing to do'
      return false
    end

    if enqueue playlist.tracks
      # set for seek position (will play from seek point)
      cmd(%Q{seek #{playlist.position} #{Integer(playlist.seek)}})
    else
      raise "Cannot load playlist #{playlist}" 
    end
  end
  
  def volume=(new_volume)
    cmd(%Q{setvol #{Integer(new_volume)}})
  end

  def enqueue(tracks)
    tracks.each do |track|
      cmd(%Q{add "#{track[:file]}"})
    end
  end

  def play(song_number=nil)
    cmd("play #{song_number}")
  end
  
  def playlist
    begin
      status = cmd('status')
      tracks = cmd('playlistinfo')
    
      playlist = PlaylistParser.parse(status, tracks)
      playlist
    rescue  Playlist::StateError,
            Playlist::ModeError,
            Playlist::PositionError,
            Playlist::SeekError,
            Playlist::VolumeError => e
      logger.warn("Playlist parsing raised error: #{e}")
      retry
    end
  end
  
  # search :artist => "Bob Marley", :exact => true
  # search :filename => './bob.mp3'
  # search "Bob Marley"
  def search(args)
    if args.nil?
      logger.error 'no query found' 
      return []
    end
    
    if args.to_s == args
      args = {'any' => args}
    end
    
    if args.delete(:exact)
      command = 'find'
    else
      command = 'search'
    end
    
    if args.keys.size > 1
      raise 'Too many arguments for search'
    end
    
    scope = args.keys.first.to_s
    term  = args.values.first
    
    unless SEARCH_SCOPE.include?(scope)
      raise "Unknown search scope #{scope}"
    end
    
    cmd_string = %Q{#{command} #{scope} "#{term}"}
        
    tracks = cmd(cmd_string)

    if tracks.respond_to?(:collect)
      tracks.collect { |t| Track.new(t) }
    else
      []
    end
  end

  def respond_to?(method)
    if COMMANDS.include?(method.to_s)
      true
    else
      super
    end
  end
  
  def method_missing(method, *args, &block)
    if COMMANDS.include?(method.to_s)
      cmd(method.to_s, *args, &block)
    else
      super
    end
  end
  
  private
  def boolean_to_s(bool)
    bool == true ? '1' : '0'
  end
end
end
