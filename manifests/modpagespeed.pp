# This depends on puppetlabs/apache: https://github.com/puppetlabs/puppetlabs-apache

class faster_apache::modpagespeed (
  $url     = $faster_apache::params::apache_mod_pagespeed_url,
  $package = $faster_apache::params::apache_mod_pagespeed_package,
  $ensure  = 'present'
) {


  $download_location = $::osfamily ? {
    'Debian' => '/tmp/mod-pagespeed.deb',
    'Redhat' => '/tmp/mod-pagespeed.rpm'
  }

  $provider = $::osfamily ? {
    'Debian' => 'dpkg',
    'Redhat' => 'yum'
  }

  exec { "download apache mod-pagespeed to ${download_location}":
    creates => $download_location,
    command => "wget ${url} -O ${download_location}",
    timeout => 30,
    path    => '/usr/bin'
  }

  package { $package:
    ensure   => $ensure,
    provider => $provider,
    source   => $download_location,
    notify   => Service['httpd']
  }

  file { [
    "${faster_apache::params::mod_dir}/pagespeed.load",
    "${faster_apache::params::mod_dir}/pagespeed.conf",
    "${faster_apache::params::confd_dir}/pagespeed_libraries.conf"
  ] :
    purge => false,
  }

  if $faster_apache::params::mod_enable_dir != undef {
    file { [
      "${faster_apache::params::mod_enable_dir}/pagespeed.load",
      "${faster_apache::params::mod_enable_dir}/pagespeed.conf"
    ] :
      purge => false,
    }
  }

}
