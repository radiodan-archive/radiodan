require 'spec_helper'
require 'player'

describe Radiodan::Player do
  context 'adapter' do
    it 'accepts an adapter' do
      adapter = mock.as_null_object
      subject.adapter = adapter
      subject.adapter.should == adapter
    end

    it 'passes itself to the adapter' do
      adapter = stub
      adapter.should_receive(:player=).with(subject)

      subject.adapter = adapter
    end
  end

  context 'playlist' do
    it 'triggers a new playlist event' do
      playlist = stub
      adapter  = mock(:player= => nil, :playlist => playlist)

      subject.adapter = adapter
      subject.should_receive(:trigger_event).with(:playlist, playlist)
      subject.should_receive(:trigger_event).with(:player_state, playlist)
      subject.playlist = playlist
    end
  end

  context 'syncs' do
    before :each do
      subject.playlist = stub.as_null_object
      subject.adapter  = stub.as_null_object
    end
    
    it 'returns false unless adapter is set' do
      subject.stub(:adapter).and_return(nil)
      subject.sync.should == false
    end
    
    it 'returns true if expected and actual state are the same' do
      Radiodan::PlaylistSync.any_instance.stub(:sync?).and_return(true)
      
      subject.sync.should == true
    end
    
    context 'sync error triggers events:' do
      before :each do
        Radiodan::PlaylistSync.any_instance.stub(:sync?).and_return(false)
        subject.should_receive(:trigger_event).with(:sync, subject.adapter.playlist)
      end
      
      it 'playback state' do
        Radiodan::PlaylistSync.any_instance.stub(:errors).and_return([:state])
        subject.adapter.playlist.stub(:state => :playing)
      
        subject.should_receive(:trigger_event).with(:play_state, :playing)
        subject.sync.should == false
      end
      
      it 'playback mode' do
        Radiodan::PlaylistSync.any_instance.stub(:errors).and_return([:mode])
        subject.adapter.playlist.stub(:mode => :random)
      
        subject.should_receive(:trigger_event).with(:play_mode, :random)
        subject.sync.should == false
      end
      
      it 'playlist' do
        Radiodan::PlaylistSync.any_instance.stub(:errors).and_return([:new_tracks])
        
        playlist_content = stub
        subject.playlist.stub(:content => playlist_content)
      
        subject.should_receive(:trigger_event).with(:playlist, subject.playlist)
        subject.sync.should == false
      end
    end
  end
end
