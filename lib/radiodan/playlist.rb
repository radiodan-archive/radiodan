=begin
  The playlist object defines the source of audio
  for the player.
  
  We cant return the name of a stored playlist from mpd: we might as well build it up
  in memory.
  
  Attributes:
    name: name of playlist (optional?)
    state: playing, stopped, paused
    mode: sequential, random, resume
    tracks: an array of URIs to play
    position: song to resume play
    seek: position to resume from (seconds)
=end
require 'forwardable'
require 'track'

class Radiodan
class Playlist
  class StateError < Exception; end
  class ModeError < Exception; end
  class PositionError < Exception; end
  class SeekError < Exception; end
  class VolumeError < Exception; end

  extend  Forwardable
  
  STATES = [:play, :stop, :pause]
  MODES  = [:sequential, :resume, :random]
  attr_reader :state, :mode, :repeat, :tracks, :position, :seek, :volume
  alias_method :repeat?, :repeat
  def_delegators :@tracks, :size, :length, :empty?

  def initialize(options={})
    self.state    = options.fetch(:state, STATES.first)
    self.mode     = options.fetch(:mode, MODES.first)
    self.repeat   = options.fetch(:repeat, false)
    self.tracks   = options.fetch(:tracks, Array.new)
    self.position = options.fetch(:position, 0)
    self.seek     = options.fetch(:seek, 0.0)
    self.volume   = options.fetch(:volume, 100)
  end

  def current
    tracks[position]
  end
  
  def random?
    self.mode == :random
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

  def tracks=(new_tracks)
    if new_tracks.is_a?(String)
      new_tracks = Track.new(file: new_tracks)
    end
    
    @tracks = Array(new_tracks)
    @position = 0
  end

  def position=(new_position)
    begin
      position = Integer(new_position)
      raise ArgumentError if position > tracks.size
    rescue ArgumentError
      raise PositionError, "Item #{new_position} invalid for playlist size #{tracks.size}"
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
    # -1 is allowed when volume cannot be determined
    begin
      new_volume = Integer(new_volume)
      
      raise ArgumentError if new_volume > 100 || new_volume < -1
    rescue ArgumentError
      raise VolumeError, "#{new_volume} not an integer -1-100"
    end
    
    @volume = new_volume
  end
end
end
