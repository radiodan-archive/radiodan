require 'net/telnet'

class MPD
  def initialize(options={})
    @port = options[:port] || 6600
    @host = options[:host] || 'localhost'
  end

  def connect
    @connect = Net::Telnet::new("Host" => @host, "Port" => @port, "Prompt" => //){ |c| print 'connect:'+c }
  end

  def radio_1
    return false unless @connect
    @connect.cmd("String" => "status", "Match" => /^OK$/) {|c| print 'status: '+c}
    puts 'stop'
    @connect.cmd("String" => "stop", "Match" => /^OK$/) {|c| print 'stop: '+c}
    puts 'clear'
    @connect.cmd("String" => "clear", "Match" => /^OK$/) {|c| print 'clear: '+c}
    puts 'load'
    @connect.cmd("String" => "load bbc_radio_1", "Match" => /^OK$/) {|c| print 'load: '+c}
    puts 'play'
    @connect.cmd("String" => "play", "Match" => /^OK$/) {|c| print 'play: '+c}
    @connect.close
  end
end

