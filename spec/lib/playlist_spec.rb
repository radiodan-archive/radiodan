require 'spec_helper'
require 'playlist'

describe Radiodan::Playlist do
  describe 'default attributes' do
    it 'has a state of stopped' do
      subject.state.should == :stopped
    end

    it 'has a playback mode of sequential' do
      subject.mode.should == :sequential
    end

    it 'has an empty array of content' do
      subject.content.should == Array.new
    end

    it 'has a starting position of zero' do
      subject.position.should == 0
    end
    
    it 'has a default seek of 0' do
      subject.seek.should == 0
    end
  end

  describe 'playback state' do
    it 'can be set' do
      subject.state = :playing
      subject.state.should == :playing
    end

    it 'cannot be set to an unknown state' do
      subject.class::STATES.should_not include :nothing
      expect { subject.state = :nothing }.to raise_error subject.class::StateError
    end
  end

  describe 'playback mode' do
    it 'can be set' do
      subject.mode = :sequential
      subject.mode.should == :sequential
    end

    it 'cannot be set to an unknown state' do
      subject.class::MODES.should_not include :inverted
      expect { subject.mode = :inverted }.to raise_error subject.class::ModeError
    end
  end

  describe 'content' do
    it 'creates an array of content' do
      subject.content = 'x.mp3'
      subject.content.size.should  == 1
      subject.content.first.should == 'x.mp3'
      subject.position.should == 1
    end

    it 'accepts an array of content' do
      subject.content = '1.mp3', '2.mp3'
      subject.content.size.should == 2
    end
  end

  describe 'starting position' do
    before :each do
      subject.content = 'a.mp3'
    end

    it 'should not be larger than the size of the playlist' do
      expect { subject.position = 1 }.to_not raise_error
      expect { subject.position = 2 }.to raise_error subject.class::PositionError
    end

    it 'should be cast to an integer' do
      subject.position = '1'
      subject.position.should == 1
    end

    it 'raises when it cannot be coerced into integer' do
      expect { subject.position = 'dave' }.to raise_error subject.class::PositionError
      subject.position.should == 1
    end
  end

  describe 'current item playing' do
    before :each do
      subject.content = %w{1.mp3 2.mp3}
    end

    it 'returns item from current position' do
      subject.position.should == 1
      subject.current.should  == '1.mp3'
    end 
  end

  describe 'seek time' do
    it 'is expressed as a integer' do
      subject.seek = '22'
      subject.seek.should == 22

      subject.seek = 22.2
      subject.seek.should == 22
    end

    it 'raises when it cannot be coerced into integer' do
      expect { subject.seek = 'dave' }.to raise_error subject.class::SeekError
      subject.seek.should == 0
    end
  end
end