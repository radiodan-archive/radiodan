require 'active_support'
require 'active_support/core_ext/string'

require 'radio/player'
require 'radio/state'

class Radio
class Builder
  attr_reader :middlewares
    
  def initialize(&blk)
    @middlewares = []
    @player = Player.new
    
    yield(self)
  end

  def use(klass, *config)
    @middlewares << register(klass, *config)
  end
  
  def player(klass=nil, *config)
    return @player if klass.nil?
    
    @player.adapter = register(klass, *config)
  end
  
  def state(options)
    @player.state = State.new(options) if @player
  end
  
  def call_middleware!
    @middlewares.each{ |m| m.call(@player) }
  end

  private
  def register(klass, *config)
    klass = klass.to_s

    begin
      radio_klass = Radio.const_get(klass.classify)
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
