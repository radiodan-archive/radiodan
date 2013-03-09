require 'rubygems'
require 'bundler/setup'
require 'eventmachine'
require 'em-synchrony'

require_relative './lib/em_additions'

require_relative './lib/radio/download'
require_relative './lib/radio/content'

namespace :import do
  desc "Import BBC Radio stations as playlists"
  task :bbc do
    EM.synchrony do
      downloader = Radio::Download::BBC.new
      
      # download BBC Radio playlists
      # Querystrings suggest each stream valid for 4 hours
      # dump this info into db,
      # so we don't have to run on every boot
      EM.now_and_every(hours: 3.9) do
        puts "Downloading BBC Streams"
        downloader.download
      end
    end
  end
end
