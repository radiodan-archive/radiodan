require 'forwardable'

require_relative './mpd/connection'
require_relative './mpd/playlist_parser'

class Radiodan
class MPD
  include Logging
  extend  Forwardable
  
  def_delegators :@connection, :cmd

  COMMANDS = %w{stop pause clear play next previous search update}  
  attr_reader :player

  def initialize(options={})
    @connection = Connection.new(options)
  end
    
  def player=(player)
    @player = player
    
    # register typical player commands
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
  end

  def playlist=(playlist)
    # get rid of current playlist, stop playback
    clear
    
    # set random & repeat
    cmd(%Q{random #{boolean_to_s(playlist.random?)}})
    cmd(%Q{repeat #{boolean_to_s(playlist.repeat?)}})
    
    # set volume
    cmd(%Q{setvol #{playlist.volume}})

    if enqueue playlist
      # set for seek position (will play from seek point)
      cmd(%Q{seek #{playlist.position} #{Integer(playlist.seek)}})
    else
      raise "Cannot load playlist #{playlist}" 
    end
  end

  def enqueue(playlist)
    playlist.tracks.each do |track|
      cmd(%Q{add "#{track[:file]}"})
    end
  end

  def play(song_number=nil)
    cmd("play #{song_number}")
  end
  
  def playlist
    status = cmd('status')
    tracks = cmd('playlistinfo')
    
    playlist = PlaylistParser.parse(status, tracks)
    # p playlist
    playlist
  end
  
  # updates music database
  def update
    cmd('update')
  end
  
  # search :artist => "Bob Marley", :exact => true
  # search :filename => './bob.mp3'
  # search "Bob Marley"
  SCOPE = %w{artist album title track name genre date composer performer comment disc filename any}
  def search(args)
    raise 'no query found' if args.nil?
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
    
    unless SCOPE.include?(scope)
      raise "Unknown search scope #{scope}"
    end
    
    cmd_string = %Q{#{command} #{scope} "#{term}"}
        
    tracks = cmd(cmd_string)

    if tracks.nil? || tracks == true
      []
    else
      tracks.collect{ |t| Track.new(t) }
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
