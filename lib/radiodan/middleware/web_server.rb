require 'thin'

class Radiodan
class WebServer
  include Logging
  
  def initialize(*config)
    @klass   = config.shift
    @options = config.shift || {}
    @port    = @options.fetch(:port, 3000)
  end
  
  def call(player)
    Thin::Server.start @klass.new(player), '0.0.0.0', @port, :signals => false
  end
end
end
