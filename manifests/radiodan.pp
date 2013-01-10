Package { ensure => "installed" }

package { "ruby1.9.3": } 

package { 'bundler':
  ensure   => 'installed',
  provider => 'gem',
}

package { "screen": } 
package { "mpd": } 
package { "mpc": } 
package { "vim": } 

service { "mpd":
  ensure => "running",
}

exec { "umute":
  command => "amixer set -c 0 Master 70 unmute && amixer set -c 0 PCM 70 unmute",
  path    => "/usr/bin/",
}

