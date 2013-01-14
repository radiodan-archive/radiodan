require 'net/telnet'

class MPD
  COMMANDS = %w{stop pause status clear}

  def initialize(options={})
    @port = options[:port] || 6600
    @host = options[:host] || 'localhost'
  end

  def connect
    @connect = Net::Telnet::new("Host" => @host, "Port" => @port, "Prompt" => //, "Mach" => /^OK$/)
    # currently here just to flush MPD info on connect
    cmd('status')
    @connect
  end

  def disconnect
    return true unless @connect
    @connect.close
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
    connect unless @connect
    options = {"String" => command, "Match" => /^OK$/}.merge(options)
    
    if block_given?
      @connect.cmd(options) { |p| yield(p) }
    else
      @connect.cmd(options).chomp
    end
  end
end

