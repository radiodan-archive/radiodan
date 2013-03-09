require 'em-simple_telnet'
require 'ostruct'

module Radio
class MPD
  include Logging
  COMMANDS = %w{stop pause status clear}
  Ack = Struct.new(:error_id, :position, :command, :description)
  
  attr_accessor :state

  def initialize(options={})
    @port     = options[:port] || 6600
    @host     = options[:host] || 'localhost'
    @settings = options[:status]    
  end

=begin
  Sync checks the current status of MPD.
  Is it paused? Playing? What is it playing?
  It compares the expected to actual statuses and
  makes changes required to keep them the same.
=end

  def sync
    current_status = status
    case
    when !state.content.files.include?(current_status.file)
      logger.debug 'update content'
      self.playlist = state.content
    when state.playback != current_status.state
      logger.debug 'update playback'
      self.send state.playback.to_sym
    else
      logger.debug 'do nothing'
      # update play position if resume
    end
  end

  def playlist=(playlist)
    # get rid of current playlist, stop playback
    clear

    if enqueue playlist
      play playlist.song_number
    else
      raise "Cannot load playlist #{playlist}" 
    end
  end

  def enqueue(playlist)
    playlist.files.each do |file|
      cmd("add #{file}")
    end
  end

  def play(song_number=nil)
    cmd("play #{song_number}")
  end
  
  def status
    @status = cmd("status")
    playlist = cmd("playlistinfo")
    
    unless playlist == true
      @status.merge!(playlist)
    end
    
    OpenStruct.new(@status)
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
    
    format_response(response)
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
      # remove first response: "OK"
      response = response.split
      response.pop

      Hash[*response.collect{|x| x.gsub(/:$/,'')}]
    end
  end
  
  def format_ack(ack)
    matches = /ACK \[(\d)+@(\d)+\] \{(.*)\} (.*)/.match(ack)    
    AckError.new(*matches[1..-1])
  end
end
end