require 'spec_helper'
require 'track'

describe Radiodan::Track do
  it "requires a file attribute" do
    expect { Radiodan::Track.new(:name => stub) }.to raise_error Radiodan::Track::NoFileError
    expect { Radiodan::Track.new(:file => stub) }.to_not raise_error
  end
  
  context "parsing attributes" do
    it "with symbols" do
      file = stub
      track = Radiodan::Track.new(:file => file)
      track[:file].should == file
      track['file'].should == file
    end
    
    it "with strings" do
      file = stub
      track = Radiodan::Track.new('file' => file)
      track[:file].should == file
      track['file'].should == file
    end
    
    it "into reader methods" do
      file = stub
      track = Radiodan::Track.new(:file => file)
      track.file.should == file
    end
  end

  context "comparison" do
    it 'is equal when files match' do
      file1 = stub
      file2 = stub
      
      Radiodan::Track.new(file: file1).should == Radiodan::Track.new(file: file1)
      Radiodan::Track.new(file: file1).should_not == Radiodan::Track.new(file: file2)
    end
  end
end
