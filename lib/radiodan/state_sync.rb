class Radiodan
class StateSync
  class SyncError < Exception; end
  attr_accessor :playlist, :state
  attr_reader   :errors
  
  def initialize(playlist = nil, state = nil)
    @playlist = playlist
    @state    = state
    @errors   = []
  end
  
  def sync?
    prerequisites_check
    compare_playback_state & compare_playback_mode & compare_playlist
  end
  
  private
  def prerequisites_check
    raise SyncError, 'No playlist to compare to' if playlist.nil?
    raise SyncError, 'No state to compare to'    if state.nil?
  end
  
  def compare_playback_state
    compare(:state) { @playlist.state == @state.state }
  end

  def compare_playback_mode
    compare(:mode) { @playlist.mode == @state.mode }
  end

  def compare_playlist
    compare(:playlist) { @playlist.content == @state.content }
  end
  
  def compare(type, &blk)
    result = blk.call
    errors << type unless result
    result
  end
end
end
