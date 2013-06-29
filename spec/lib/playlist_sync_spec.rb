require 'spec_helper'
require 'playlist_sync'

describe Radiodan::PlaylistSync do
  subject(:playlist_sync) do
    Radiodan::PlaylistSync.new \
      stub(:state => nil, :mode => nil, :tracks => [], :size => 0),
      stub(:state => nil, :mode => nil, :tracks => [], :size => 0)
  end
  
  context 'prerequisites for sync' do
    it 'requires expected playlist' do
      playlist_sync.expected = nil
      expect { playlist_sync.sync? }.to raise_error(Radiodan::PlaylistSync::SyncError)
    end
    
    it 'requires current state' do
      playlist_sync.current = nil
      expect { playlist_sync.sync? }.to raise_error(Radiodan::PlaylistSync::SyncError)
    end
  end
  
  context 'playback state' do
    before :each do
      playlist_sync.stub(:compare_playback_mode => true, :compare_playlist => true)
      playlist_sync.expected.stub(:state => :playing)
    end
    
    it 'catches non-matching state' do
      playlist_sync.current.stub(:state => :paused)

      playlist_sync.sync?.should  == false
      playlist_sync.errors.should == [:state]
    end
    
    it 'allows matching state' do
      playlist_sync.current.stub(:state => :playing)
      playlist_sync.sync?.should == true
      playlist_sync.errors.should be_empty
    end
  end

  context 'playback mode' do
    before :each do
      playlist_sync.stub(:compare_playback_state => true, :compare_playlist => true)
      playlist_sync.expected.stub(:mode => :random)
    end
    
    it 'catches non-matching state' do
      playlist_sync.current.stub(:mode => :resume)

      playlist_sync.sync?.should  == false
      playlist_sync.errors.should == [:mode]
    end
    
    it 'allows matching state' do
      playlist_sync.current.stub(:mode => :random)
      playlist_sync.sync?.should == true
      playlist_sync.errors.should be_empty
    end
  end
  
  context 'playlists' do
    before :each do
      playlist_sync.stub(:compare_playback_mode => true, :compare_playback_state => true)
      playlist_sync.expected.stub(:tracks => [1,2,3,4], :size => 4)
    end
    
    it 'catches non-matching tracks' do
      playlist_sync.current.stub(:tracks => [], :size => 4)

      playlist_sync.sync?.should  == false
      playlist_sync.errors.should == [:playlist]
    end
    
    it 'catches non-matching size' do
      playlist_sync.current.stub(:tracks => [1,2,3,4], :size => 2)

      playlist_sync.sync?.should  == false
      playlist_sync.errors.should == [:playlist]
    end
    
    it 'allows matching state' do
      playlist_sync.current.stub(:tracks => [1,2,3,4], :size => 4)
      playlist_sync.sync?.should == true
      playlist_sync.errors.should be_empty
    end
  end
  
  context 'error messages' do
    it 'captures multiple errors' do
      playlist_sync.expected.stub(:tracks => [1], :mode => :random, :size => 1)
      playlist_sync.sync?.should  == false
      playlist_sync.errors.should == [:mode, :playlist]
    end
  end
end