State Management
----------------

Two kinds of state:


1.  Requested state AKA a playlist
  *"This is what I want the player to be doing"*
  
  Includes:
   * a Radiodan::Content object, defining a playlist of content
   * a playback
    * playing
    * stopped
    * paused?
    * resume (play from position)

  Examples:
    * Play radio 1
    * Play from this artist at random
    * Resume play on this playlist from a defined position
    * Don't play anything!

2. Player feedback state
  *"This is what the player is currently doing"*
  
  Examples:
    * Playing track x.mp3 at 1m15s
    * Playing <URL> for 5 minutes

When the player syncs, we want to make sure the player state is within the parameters set by the request.

  e.g. We don't expect the playlist to always be playing at a defined position, just that it resumed from there and that it is still playing the same set of podcasts.

You set expected state when you want the player to change direction.
Expected state defines how to respond to player state.

You want feedback info in order to populate feedback displays. When you ask the player what it's state is, you want this information.

    radio = Radiodan.new
    
    radio.playlist = Radiodan::Playlist.new(:playback => :playing, :content => :bbcradio1)
    radio.state   #=> <playing (radio1_url)>
    radio.sync?   #=> true
