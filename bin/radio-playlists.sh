#!/bin/sh
playlists=$(dirname "$0")/../playlists

for RADIO in 1 1x 2 3 4 4lw 4x 5l 5lsp 6; do
  curl -s http://www.bbc.co.uk/radio/listen/live/r${RADIO}_aaclca.pls | grep File1 | cut -d'=' -f2- > $playlists/bbc_radio_${RADIO}.m3u
done

