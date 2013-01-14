#!/usr/bin/env ruby
require_relative '../lib/mpd'

@mpd = MPD.new
@mpd.connect
@mpd.radio_1


