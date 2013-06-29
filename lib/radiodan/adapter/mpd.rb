require 'forwardable'

require_relative './mpd/connection'
require_relative './mpd/playlist_parser'

class Radiodan
class MPD
  include Logging
  extend  Forwardable
  
  def_delegator :@connection, :cmd, :cmd

  COMMANDS = %w{stop pause clear play}  
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

    if enqueue playlist
      play playlist.position
    else
      raise "Cannot load playlist #{playlist}" 
    end
  end

  def enqueue(playlist)
    playlist.content.each do |file|
      cmd(%Q{add "#{file}"})
    end
  end

  def play(song_number=nil)
    cmd("play #{song_number}")
  end
  
  def playlist
    status = cmd("status")
    playlist = cmd("playlistinfo")
    
    PlaylistParser.parse(status, playlist)
  end

  def respond_to?(method)
    if COMMANDS.include?(method.to_s)
      true
    else
      super
    end
  end
  
  private
  def method_missing(method, *args, &block)
    if COMMANDS.include?(method.to_s)
      cmd(method.to_s, *args, &block)
    else
      super
    end
  end
end
end
