require 'spec_helper'
require 'playlist_sync'
require 'playlist'

describe Radiodan::PlaylistSync do
  subject(:playlist_sync) do
    playlist = Radiodan::Playlist.new tracks: [mock]
    
    Radiodan::PlaylistSync.new \
      playlist,
      playlist.dup
  end
  
  context 'prerequisites for sync' do
    it 'requires expected playlist' do
      playlist_sync.expected = nil
      playlist_sync.ready?.should == false
    end
    
    it 'requires current state' do
      playlist_sync.current = nil
      playlist_sync.ready?.should == false
    end
  end
  
  context 'playback state' do
    before :each do
      playlist_sync.stub(:compare_playback_mode => true, :compare_playlist => true)
      playlist_sync.expected.state = :play
    end
    
    it 'catches non-matching state' do
      playlist_sync.current.state = :pause

      playlist_sync.sync?.should  == false
      playlist_sync.errors.should == [:state]
    end
    
    it 'allows matching state' do
      playlist_sync.current.state = :play
      playlist_sync.sync?.should == true
      playlist_sync.errors.should be_empty
    end
  end

  context 'playback mode' do
    before :each do
      playlist_sync.stub(:compare_playback_state => true, :compare_playlist => true)
      playlist_sync.expected.mode = :random
    end
    
    it 'catches non-matching state' do
      playlist_sync.current.mode = :resume

      playlist_sync.sync?.should  == false
      playlist_sync.errors.should == [:mode]
    end
    
    it 'allows matching state' do
      playlist_sync.current.mode = :random
      playlist_sync.sync?.should == true
      playlist_sync.errors.should be_empty
    end
  end
  
  context 'volume' do
    before :each do
      playlist_sync.stub(:compare_playback_state => true, :compare_playlist => true, :compare_playback_mode => true)
      playlist_sync.expected.volume = 90
    end
    
    it 'catches non-matching state' do
      playlist_sync.current.volume = 70

      playlist_sync.sync?.should  == false
      playlist_sync.errors.should == [:volume]
    end
    
    it 'allows matching state' do
      playlist_sync.current.volume = 90
      playlist_sync.sync?.should == true
      playlist_sync.errors.should be_empty
    end
  end
  
  context 'playlists' do
    before :each do
      playlist_sync.stub(:compare_playback_mode => true, :compare_playback_state => true)
      playlist_sync.expected.tracks = [1,2,3,4]
    end
    
    it 'catches non-matching tracks' do
      playlist_sync.current.tracks = [5,6,7]

      playlist_sync.sync?.should  == false
      playlist_sync.errors.should == [:new_tracks]
    end
    
    it 'catches tracks in new order' do
      playlist_sync.current.tracks = [2,1]

      playlist_sync.sync?.should  == false
      playlist_sync.errors.should == [:new_tracks]
    end
    
    it 'catches additional tracks' do
      playlist_sync.current.tracks = [1,2]
      
      playlist_sync.sync?.should  == false
      playlist_sync.errors.should == [:add_tracks]
    end

    it 'allows matching state' do
      playlist_sync.current.tracks = [1,2,3,4]
      playlist_sync.sync?.should == true
      playlist_sync.errors.should be_empty
    end
  end
  
  context 'error messages' do
    it 'captures multiple errors' do
      playlist_sync.expected.tap{ |x| x.tracks = [1];  x.mode = :random }
      playlist_sync.sync?.should  == false
      playlist_sync.errors.should == [:mode, :new_tracks]
    end
  end
end