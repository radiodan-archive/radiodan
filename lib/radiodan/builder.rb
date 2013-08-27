require 'active_support'
require 'active_support/core_ext/string'
require 'pathname'

require 'logging'
require 'player'

class Radiodan
class Builder
  attr_reader :middleware, :player
    
  def initialize(&blk)
    @middleware = []
    @player = Player.new
    
    yield(self) if block_given?
  end

  def use(klass, *config)
    @middleware << register(klass, 'middleware', *config)
  end
  
  def adapter(klass, *config)
    player.adapter = register(klass, 'adapter', *config)
  end
  
  def playlist(new_playlist)
    use :playlist_to_start, new_playlist
  end
  
  def log(log)
    Logging.output = log
  end
  
  def call_middleware!
    middleware.each{ |m| m.call(@player) }
  end

  private
  def register(klass, klass_type, *config)
    klass = klass.to_s

    begin
      radio_klass = Radiodan.const_get(klass.classify)
    rescue NameError => e
      klass_path ||= false
      raise if klass_path
      
      # attempt to require from given path
      klass_path = Pathname.new(File.join(File.dirname(__FILE__), klass_type, "#{klass.underscore}.rb"))
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
