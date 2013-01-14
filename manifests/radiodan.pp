exec { "apt-update":
  command => "/usr/bin/apt-get update",
}

Exec["apt-update"] -> Package <| |>
Package { ensure => "installed" }

package { "ruby1.9.3": } 

package { 'bundler':
  ensure   => 'installed',
  provider => 'gem',
  require => Package['ruby1.9.3'],
}

package { "vim": } 
package { "screen": } 

package { "mpd": } 
package { "mpc": } 
package { "ncmpcpp": } 
package { "alsa-utils": } 
package { "curl": } 

service { "mpd":
  ensure => "running",
  require => Package['mpd'],
}

exec { "radio-playlists":
  command => "/vagrant/bin/radio-playlists.sh",
  require => Package['curl'],
}

exec { "umute":
  command => "amixer set -c 0 Master 70 unmute && amixer set -c 0 PCM 70 unmute",
  path    => "/usr/bin/",
  require => Package['alsa-utils'],
}

file { '/etc/mpd.conf':
  ensure  => present,
  require => Package['mpd'],
  notify => Service['mpd'],
  content => '
    music_directory    "/vagrant/music"
    playlist_directory "/vagrant/playlists"
    db_file            "/var/lib/mpd/tag_cache"
    log_file           "/var/log/mpd/mpd.log"
    pid_file           "/var/run/mpd/pid"
    user               "mpd"
    bind_to_address    "localhost"
    port               "6600"
    auto_update        "yes"

    audio_output {
            type            "alsa"
            name            "My ALSA Device"
            device          "hw:0,0"
            format          "44100:16:2"    
            mixer_device    "default"
            mixer_control   "PCM"
            mixer_index     "0"
    }
  ',
}

