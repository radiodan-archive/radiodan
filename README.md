radiodan
========

Web-enabled radio that plays to my schedule.

Installation
------------

* `bundle install`
* copy `config.example.yml` to `config.yml`
* add `precise64-audio.box` to vagrant
* `vagrant up`
* `vagrant ssh` to log into machine
* move to /vagrant
* `bundle install` the local code
* run `./bin/download` to get the BBC playlists
* run `./bin/radio` to start the radio server.

