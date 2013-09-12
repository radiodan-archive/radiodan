require 'logging'

class Radiodan
class PlaylistSync
  include Logging
  
  class SyncError < Exception; end
  attr_accessor :expected, :current
  attr_reader   :errors
  
  def initialize(expected = nil, current = nil)
    @expected = expected
    @current  = current
    @errors   = []
  end
  
  def sync?
    if ready?
      compare_playback_state & compare_playback_mode & compare_tracks & compare_volume
    end
  end
  
  def ready?
    if expected.nil? || current.nil?
      logger.warn 'Require two playlists to compare'
      false
    else
      true
    end
  end
  
  private
  def compare_playback_state
    # add rules about when this is ok to be out of sync
    # e.g. sequential expected runs out of tracks and stops
    report(:state) { @expected.state != @current.state }
  end

  def compare_playback_mode
    report(:mode) { @expected.mode != @current.mode }
  end

  def compare_tracks
    report(:add_tracks) do
      # more tracks are added and
      # original tracks are all in the same position in playlist
      @expected.size > @current.size && !@current.empty? &&
      @current.tracks.all? {|x| i=@current.tracks.index(x); @expected.tracks[i] == x }
    end
    
    return false if errors.include?(:add_tracks)
    
    report(:new_tracks) do
      @expected.size != @current.size ||
      @expected.tracks != @current.tracks
    end
  end
  
  def compare_volume
    report(:volume) do
      @expected.volume != @current.volume
    end
  end
  
  def report(type, &blk)
    result = blk.call
    errors << type if result
    !result
  end
end
end
