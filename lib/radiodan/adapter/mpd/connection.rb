require 'em-simple_telnet'
require 'logging'

require_relative 'response'

class Radiodan
class MPD
class Connection
  include Logging
  
  def initialize(options={})
    @port = options[:port] || 6600
    @host = options[:host] || 'localhost'
  end
  
  def cmd(command, options={})
    options = {match: /^(OK|ACK)/}.merge(options)
    response = nil
    
    EM::P::SimpleTelnet.new(host: @host, port: @port, prompt: /^(OK|ACK)(.*)$/) do |host|
      host.waitfor(/^OK MPD \d{1,2}\.\d{1,2}\.\d{1,2}$/)
      logger.debug command
      result = host.cmd(command, options).strip
      response = Response.new(result, command)
    end
    
    response
  end
end
end
end
