exec { "apt-update":
    command => "/usr/bin/apt-get update"
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

service { "mpd":
  ensure => "running",
  require => Package['mpd'],
}

exec { "umute":
  command => "amixer set -c 0 Master 70 unmute && amixer set -c 0 PCM 70 unmute",
  path    => "/usr/bin/",
  require => Package['alsa-utils'],
}

