require 'spec_helper'
require 'builder'

describe Radiodan::Builder do
  before :each do
    @player = mock
    Radiodan::Player.stub(:new).and_return(@player)
  end

  it 'passes a playlist to the correct middleware' do
    playlist = mock
    
    Radiodan::Builder.any_instance.should_receive(:use).with(:playlist_to_start, playlist)

    builder = Radiodan::Builder.new do |b|
      b.playlist playlist
    end
  end

  it 'passes an instance of an adapter class with options to the player' do
    class Radiodan::MockAdapter; end
    adapter, options = mock, mock

    Radiodan::MockAdapter.should_receive(:new).with(options).and_return(adapter)

    @player.should_receive(:adapter=).with(adapter)

    builder = Radiodan::Builder.new do |b|
      b.adapter :mock_adapter, options
    end
  end

  describe 'middleware' do
    it 'creates an instance of middleware and stores internally' do
      class Radiodan::MockMiddle; end

      options, middleware = mock, mock
      Radiodan::MockMiddle.should_receive(:new).with(options).and_return(middleware)

      builder = Radiodan::Builder.new do |b|
        b.use :mock_middle, options
      end
      
      builder.middleware.size.should == 1
      builder.middleware.should include middleware
    end

    it 'executes middleware, passing player instance' do
      middleware = stub
      middleware.should_receive(:call).with(@player)

      builder = Radiodan::Builder.new
      builder.should_receive(:middleware).and_return([middleware])
      builder.call_middleware!
    end
  end
end
