require 'spec_helper'
require 'state_sync'

describe Radiodan::StateSync do
  subject(:state_sync) do
    Radiodan::StateSync.new \
      stub(:state => nil, :mode => nil, :content => []),
      stub(:state => nil, :mode => nil, :content => [])
  end
  
  context 'prerequisites for sync' do
    it 'requires a playlist' do
      state_sync.playlist = nil
      expect { state_sync.sync? }.to raise_error(Radiodan::StateSync::SyncError)
    end
    
    it 'requires a player state' do
      state_sync.state = nil
      expect { state_sync.sync? }.to raise_error(Radiodan::StateSync::SyncError)
    end
  end
  
  context 'playback state' do
    before :each do
      state_sync.playlist.stub(:state => :playing)
    end
    
    it 'catches non-matching state' do
      state_sync.state.stub(:state => :paused)

      state_sync.sync?.should eql false
      state_sync.errors.should eql [:state]
    end
    
    it 'allows matching state' do
      state_sync.state.stub(:state => :playing)
      state_sync.sync?.should eql true
      state_sync.errors.should be_empty
    end
  end

  context 'playback mode' do
    before :each do
      state_sync.playlist.stub(:mode => :random)
    end
    
    it 'catches non-matching state' do
      state_sync.state.stub(:mode => :resume)

      state_sync.sync?.should eql false
      state_sync.errors.should eql [:mode]
    end
    
    it 'allows matching state' do
      state_sync.state.stub(:mode => :random)
      state_sync.sync?.should eql true
      state_sync.errors.should be_empty
    end
  end
  
  context 'playlists' do
    before :each do
      state_sync.playlist.stub(:content => [1,2,3,4])
    end
    
    it 'catches non-matching state' do
      state_sync.state.stub(:content => [1,4])

      state_sync.sync?.should eql false
      state_sync.errors.should eql [:playlist]
    end
    
    it 'allows matching state' do
      state_sync.state.stub(:content => [1,2,3,4])
      state_sync.sync?.should eql true
      state_sync.errors.should be_empty
    end
  end
  
  context 'error messages' do
    it 'captures multiple errors' do
      state_sync.playlist.stub(:content => [1], :mode => :random)
      state_sync.sync?.should eql false
      state_sync.errors.should eql [:mode, :playlist]
    end
  end
end