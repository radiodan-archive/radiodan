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
    compare_playback_state & compare_playback_mode & compare_playlist
  end
  
  private
  def prerequisites_check
    raise SyncError, 'No expected playlist to compare to' if expected.nil?
    raise SyncError, 'No current playlist to compare to'  if current.nil?
  end
  
  def compare_playback_state
    # add rules about when this is ok to be out of sync
    # e.g. sequential expected runs out of tracks and stops
    compare(:state) { @expected.state == @current.state }
  end

  def compare_playback_mode
    compare(:mode) { @expected.mode == @current.mode }
  end

  def compare_playlist
    compare(:playlist) do
      @expected.size == @current.size && \
      @expected.tracks == @current.tracks
    end
  end
  
  def compare(type, &blk)
    result = blk.call
    errors << type unless result
    result
  end
end
end
