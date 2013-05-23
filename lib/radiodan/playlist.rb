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

  STATES = [:stopped, :playing, :paused]
  MODES  = [:sequential, :random, :resume]
  attr_reader :state, :mode, :content, :position, :seek

  def initialize(options={})
    self.state    = options.fetch(:state, STATES.first)
    self.mode     = options.fetch(:mode, MODES.first)
    self.content  = options.fetch(:content, Array.new)
    self.position = options.fetch(:position, (content.empty? ? 0 : 1))
    self.seek     = options.fetch(:seek, 0)
  end

  def current
    if position == 0
      nil
    else
      content[position-1]
    end
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

  def content=(new_content)
    @content = Array(new_content)

    if self.position == 0 and not @content.empty?
      self.position = 1
    end
  end

  def position=(new_position)
    begin
      position = Integer(new_position)
    rescue ArgumentError
      raise PositionError
    end

    if position > content.size
      raise PositionError
    end

    @position = position
  end

  def seek=(new_seek)
    begin
      @seek = Integer(new_seek)
    rescue ArgumentError
      raise SeekError
    end
  end
end
end
