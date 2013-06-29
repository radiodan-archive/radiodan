require 'em-simple_telnet'

require_relative './mpd/playlist_parser'

class Radiodan
class MPD
  include Logging
  COMMANDS = %w{stop pause clear play}
  Ack = Struct.new(:error_id, :position, :command, :description)
  class AckError < Exception; end
  
  attr_reader :player

  def initialize(options={})
    @port = options[:port] || 6600
    @host = options[:host] || 'localhost'
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

  def cmd(command, options={})
    options = {match: /^(OK|ACK)/}.merge(options)
    response = false
    
    connect do |c|
      begin
        logger.debug command
        response = c.cmd(command, options).strip
      rescue Exception => e
        logger.error "#{command}, #{options} - #{e.to_s}"
        raise
      end
    end
    
    formatted_response = format_response(response)
  end
  
  def connect(&blk)
    EM::P::SimpleTelnet.new(host: @host, port: @port, prompt: /^(OK|ACK)(.*)$/) do |host|
      host.waitfor(/^OK MPD \d{1,2}\.\d{1,2}\.\d{1,2}$/)
      yield(host)
    end
  end
  
  # returns true or hash of values
  def format_response(response)
    case
    when response == 'OK'
      true
    when response =~ /^ACK/
      ack = format_ack(response)
      logger.warn ack
      
      ack
    when response.split.size == 1
      # set value -> value
      Hash[*(response.split.*2)]
    else
      response = response.split("\n")
      # remove first response: "OK"
      response.pop
      
      split_response = response.collect do |r| 
        split = r.split(':')
        key   = split.shift
        value = split.join(':')
        [key.strip, value.strip]
      end.flatten
      
      Hash[*split_response]
    end
  end
  
  def format_ack(ack)
    matches = /ACK \[(\d)+@(\d)+\] \{(.*)\} (.*)/.match(ack)    
    AckError.new(*matches[1..-1].join)
  end
end
end
