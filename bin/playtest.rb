#!/usr/bin/env ruby
require_relative '../lib/mpd'

@mpd = MPD.new
@mpd.connect
@mpd.playlist ARGV[0] || "bbc_radio_4"
@mpd.disconnect

