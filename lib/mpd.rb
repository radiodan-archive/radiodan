require 'em-simple_telnet'

class MPD
  COMMANDS = %w{stop pause status clear}

  def initialize(options={})
    @port = options[:port] || 6600
    @host = options[:host] || 'localhost'
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
    response = cmd("load #{playlist}", "Match" => /(OK|No such playlist)/)
    response == 'OK'
  end

  def play(song_number=nil)
    response = cmd("play #{song_number}")
    response == 'OK'
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
      puts "MPD: #{command}"
      response = c.cmd(command, options).strip
    end
    
    response
  end
  
  private
  def connect(&blk)
    EM::P::SimpleTelnet.new(host: @host, port: @port, prompt: /^OK$/) do |host|
      host.waitfor(/^OK MPD \d{1,2}\.\d{1,2}\.\d{1,2}$/)
      yield(host)
    end
  end
end
