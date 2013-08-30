require 'spec_helper'
require 'playlist'

describe Radiodan::Playlist do
  describe 'default attributes' do
    it 'has a state of stop' do
      subject.state.should == :stop
    end
    
    it 'has a state of play if there are tracks' do
      subject.tracks << mock
      subject.state.should == :play
    end

    it 'has a playback mode of sequential' do
      subject.mode.should == :sequential
    end
    
    it 'has a repeat value of false' do
      subject.repeat.should == false
    end

    it 'has an empty array of tracks' do
      subject.tracks.should == Array.new
    end

    it 'has a starting position of zero' do
      subject.position.should == 0
    end
    
    it 'has a default seek of 0.0' do
      subject.seek.should == 0.0
    end
    
    it 'has a default volume of 100%' do
      subject.volume.should == 100
    end
  end

  describe 'playback state' do
    it 'is always stop if playlist is empty' do
      subject.empty?.should be_true

      subject.state = :pause
      subject.state.should == :stop
      
      subject.tracks << mock
      
      subject.empty?.should be_false
      subject.state.should == :pause
    end
    
    it 'can be set if tracks are present' do
      subject.tracks << mock
      subject.state = :pause
      subject.state.should == :pause
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
  
  describe 'repeat mode' do
    it 'can be set' do
      subject.repeat = true
      subject.repeat.should == true
    end
    
    it 'is only set to true when passed TrueClass' do
      subject.repeat = 1
      subject.repeat.should == false
      
      subject.repeat = 'true'
      subject.repeat.should == false
    end
  end

  describe 'random mode' do
    it 'is off by default' do
      subject.random?.should == false
    end
    
    it 'can be set' do
      subject.mode = :random
      subject.random?.should == true
    end
  end

  describe 'tracks' do
    it 'creates an array of tracks' do
      subject.tracks = 'x.mp3'
      subject.tracks.size.should  == 1
      subject.tracks.first.should == {file: 'x.mp3'}
      subject.position.should == 0
    end

    it 'accepts an array of tracks' do
      subject.tracks = '1.mp3', '2.mp3'
      subject.tracks.size.should == 2
    end
  end

  describe 'starting position' do
    before :each do
      subject.tracks = 'a.mp3'
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
      subject.position.should == 0
    end
  end

  describe 'current item playing' do
    before :each do
      subject.tracks = %w{1.mp3 2.mp3}
    end

    it 'returns item from current position' do
      subject.position.should == 0
      subject.current.should  == '1.mp3'
    end 
  end

  describe 'seek time' do
    it 'is expressed as a float' do
      subject.seek = '22'
      subject.seek.should == 22.0

      subject.seek = 22.2
      subject.seek.should == 22.2
    end

    it 'raises when it cannot be coerced into a float' do
      expect { subject.seek = 'dave' }.to raise_error subject.class::SeekError
      subject.seek.should == 0.0
    end
  end
  
  describe 'volume' do
    it 'is expressed as an integer' do
      subject.volume = '24'
      subject.volume.should == 24
    end
    
    it 'has a legal range of -1-100' do
      expect { subject.volume = '999' }.to raise_error subject.class::VolumeError
      expect { subject.volume = -29 }.to raise_error subject.class::VolumeError
      subject.volume.should == 100
    end
  end
  
  describe 'attributes' do
    it 'should be well formed' do
      expected = {:state=>:stop, :mode=>:sequential, :repeat=>false, :tracks=>[], :position=>0, :seek=>0.0, :volume=>100}
      expect subject.attributes.should == expected
    end
    
    it 'should include track attributes' do
      subject.tracks << Radiodan::Track.new(:file => 'dan.mp3')
      expected = {:state=>:play, :mode=>:sequential, :repeat=>false, :tracks=>[{'file' => 'dan.mp3'}], :position=>0, :seek=>0.0, :volume=>100}
      expect subject.attributes.should == expected      
    end
  end
end
