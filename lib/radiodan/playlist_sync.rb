class Radiodan
class PlaylistSync
  class SyncError < Exception; end
  attr_accessor :expected, :current
  attr_reader   :errors
  
  def initialize(expected = nil, current = nil)
    @expected = expected
    @current  = current
    @errors   = []
  end
  
  def sync?
    prerequisites_check
    compare_playback_state & compare_playback_mode & compare_tracks
  end
  
  private
  def prerequisites_check
    raise SyncError, 'No expected playlist to compare to' if expected.nil?
    raise SyncError, 'No current playlist to compare to'  if current.nil?
  end
  
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
  
  def report(type, &blk)
    result = blk.call
    errors << type if result
    !result
  end
end
end
