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

