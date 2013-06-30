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
    
    connect do |c|
      begin
        logger.debug command
        result = c.cmd(command, options).strip
        Response.new(result, command)
      rescue Exception => e
        logger.error "#{command}, #{options} - #{e.to_s}"
        raise
      end
    end
  end

  private
  def connect(&blk)
    response = nil
    EM::P::SimpleTelnet.new(host: @host, port: @port, prompt: /^(OK|ACK)(.*)$/) do |host|
      host.waitfor(/^OK MPD \d{1,2}\.\d{1,2}\.\d{1,2}$/)
      response = yield(host)
    end
    
    response
  end
end
end
end
