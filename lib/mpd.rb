require 'em-simple_telnet'
require 'active_support/hash_with_indifferent_access'

class MPD
  COMMANDS = %w{stop pause status clear}
  attr_accessor :playlists

  def initialize(options={})
    @port     = options[:port] || 6600
    @host     = options[:host] || 'localhost'
    @settings = options[:status]
  end

  def sync
    current_status = status
    case
    when current_status[:file] != playlists[@settings[:playlist]]
      playlist @settings[:playlist]
    when current_status[:state] != @settings[:state]
      play
    else
      # all good, do nothing
    end
  end

  def playlist(playlist)
    clear

    if enqueue playlist
      play
    else
      raise "Cannot load playlist #{playlist}" 
    end
  end

  def enqueue(playlist)
    cmd("load #{playlist}", "Match" => /(OK|No such playlist)/)
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
    
    @status
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
    options = {match: /^OK$/}.merge(options)
    response = false
    
    connect do |c|
      # puts "MPD: #{command}"
      response = c.cmd(command, options).strip
    end
    
    format_response(response)
  end
  
  def connect(&blk)
    EM::P::SimpleTelnet.new(host: @host, port: @port, prompt: /^OK$/) do |host|
      host.waitfor(/^OK MPD \d{1,2}\.\d{1,2}\.\d{1,2}$/)
      yield(host)
    end
  end
  
  def format_response(response)
    return true if response == 'OK'
    response = response.split
    return response.first if response.size == 1
    response.pop
    HashWithIndifferentAccess[*response.collect{|x| x.gsub(/:$/,'')}]
  end
end
