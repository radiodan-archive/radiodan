require 'active_support'
require 'active_support/core_ext/string'

require 'radiodan/logging'
require 'radiodan/player'
require 'radiodan/state'

class Radiodan
class Builder
  attr_reader :middleware, :player
    
  def initialize(&blk)
    @middleware = []
    @player = Player.new
    
    yield(self)
  end

  def use(klass, *config)
    @middleware << register(klass, *config)
  end
  
  def adapter(klass, *config)
    @player.adapter = register(klass, *config)
  end
  
  def state(options)
    @player.state = State.new(options) if @player
  end
  
  def log(log)
    Logging.output = log
  end
  
  def call_middleware!
    @middleware.each{ |m| m.call(@player) }
  end

  private
  def register(klass, *config)
    klass = klass.to_s

    begin
      radio_klass = Radiodan.const_get(klass.classify)
    rescue NameError => e
      klass_path ||= false
      raise if klass_path
      
      # attempt to require from middleware
      klass_path = Pathname.new("#{File.dirname(__FILE__)}/middleware/#{klass.underscore}.rb")
      require klass_path if klass_path.exist?
      
      retry
    end

    if config.empty?
      radio_klass.new
    else
      radio_klass.new(*config)
    end
  end
end
end
