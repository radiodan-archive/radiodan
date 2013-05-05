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
      playlist = mock

      subject.should_receive(:trigger_event).with(:playlist, playlist)
      subject.playlist = playlist
    end
  end

  context 'syncs' do
    before :each do
    end

    it 'returns false unless adapter is set' do
      subject.adapter.should be nil
      subject.sync.should == false
    end

    it 'tracks playback state'
    it 'tracks playlist content'
  end
end
