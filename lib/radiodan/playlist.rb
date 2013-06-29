=begin
  The playlist object defines the source of audio
  for the player.
  
  We cant return the name of a stored playlist from mpd: we might as well build it up
  in memory.
  
  Attributes:
    name: name of playlist (optional?)
    state: playing, stopped, paused
    mode: sequential, random, resume
    content: an array of URIs to play
    position: song to resume play
    seek: position to resume from (seconds)
=end

class Radiodan
class Playlist
  class StateError < Exception; end
  class ModeError < Exception; end
  class PositionError < Exception; end
  class SeekError < Exception; end
  class VolumeError < Exception; end

  STATES = [:play, :stop, :pause]
  MODES  = [:sequential, :resume, :random]
  attr_reader :state, :mode, :repeat, :content, :position, :seek, :volume

  def initialize(options={})
    self.state    = options.fetch(:state, STATES.first)
    self.mode     = options.fetch(:mode, MODES.first)
    self.repeat   = options.fetch(:repeat, false)
    self.content  = options.fetch(:content, Array.new)
    self.position = options.fetch(:position, 0)
    self.seek     = options.fetch(:seek, 0.0)
    self.volume   = options.fetch(:volume, 100)
  end

  def current
    content[position]
  end

  def state=(new_state)
    state = new_state.to_sym

    if STATES.include? state
      @state = state
    else
      raise StateError
    end
  end

  def mode=(new_mode)
    mode = new_mode.to_sym

    if MODES.include? mode
      @mode = mode
    else
      raise ModeError
    end
  end
  
  def repeat=(new_repeat)
    @repeat = (new_repeat === true)
  end

  def content=(new_content)
    @content = Array(new_content)
    @position = 0
  end

  def position=(new_position)
    begin
      position = Integer(new_position)
      raise ArgumentError if position > content.size
    rescue ArgumentError
      raise PositionError, "Item #{new_position} invalid for playlist size #{content.size}"
    end

    @position = position
  end

  def seek=(new_seek)
    begin
      @seek = Float(new_seek)
    rescue ArgumentError
      raise SeekError, "#{new_seek} invalid"
    end
  end
  
  def volume=(new_volume)
    begin
      new_volume = Integer(new_volume)
      
      raise ArgumentError if new_volume > 100 || new_volume < 0
    rescue ArgumentError
      raise VolumeError, "#{new_volume} not an integer 0-100"
    end
    
    @volume = new_volume
  end
end
end
