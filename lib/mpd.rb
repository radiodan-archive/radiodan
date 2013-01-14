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
    @connect.cmd("status") {|c| print 'status: '+c}
    puts 'stop'
    @connect.cmd("stop") {|c| print 'stop: '+c}
    puts 'clear'
    @connect.cmd("clear") {|c| print 'clear: '+c}
    puts 'load'
    @connect.cmd("load bbc_radio_1") {|c| print 'load: '+c}
    puts 'play'
    @connect.cmd("play") {|c| print 'play: '+c}
    @connect.close
  end
end

