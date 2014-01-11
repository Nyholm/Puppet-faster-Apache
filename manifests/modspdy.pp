# This depends on puppetlabs/apache: https://github.com/puppetlabs/puppetlabs-apache

class nyholm::faster_apache::modspdy (
  $url     = $nyholm::faster_apache::params::apache_mod_spdy_url,
  $package = $nyholm::faster_apache::params::apache_mod_spdy_package,
  $phpcgi  = $nyholm::faster_apache::params::apache_mod_spdy_cgi,
  $ensure  = 'present'
) {

  class { 'apache::mod::php':
    package_ensure => 'purged'
  }

  if $::osfamily == 'Debian' {
    if ! defined(Package['php5-cgi']) {
      package { 'php5-cgi':
        ensure  => present
      }
    }
    if ! defined(Package['libapache2-mod-fcgid']) {
      package { 'libapache2-mod-fcgid':
        ensure => present,
        notify => Service['httpd']
      }
    }
  } elsif $::osfamily == 'Redhat' {
    if ! defined(Package['php-cgi']) {
      package { 'php-cgi':
        ensure  => present,
        notify => Service['httpd']
      }
    }
    if ! defined(Package['mod_fcgid']) {
      package { 'mod_fcgid':
        ensure  => present,
        notify => Service['httpd']
      }
    }
  }

  if ! defined(Class['apache::mod::fcgid']) {
    class { 'apache::mod::fcgid': }
  }

  if ! defined(Class['apache::mod::cgi']) {
    class { 'apache::mod::cgi': }
  }

  $download_location = $::osfamily ? {
    'Debian' => '/.puphpet-stuff/mod-spdy.deb',
    'Redhat' => '/.puphpet-stuff/mod-spdy.rpm'
  }

  $provider = $::osfamily ? {
    'Debian' => 'dpkg',
    'Redhat' => 'yum'
  }

  exec { "download apache mod-spdy to ${download_location}":
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
    "${nyholm::faster_apache::params::mod_dir}/spdy.load",
    "${nyholm::faster_apache::params::mod_dir}/spdy.conf",
    "${nyholm::faster_apache::params::mod_dir}/php5filter.conf"
  ] :
    purge => false,
  }

  if $nyholm::faster_apache::params::mod_enable_dir != undef {
    file { [
      "${nyholm::faster_apache::params::mod_enable_dir}/spdy.load",
      "${nyholm::faster_apache::params::mod_enable_dir}/spdy.conf",
      "${nyholm::faster_apache::params::mod_enable_dir}/php5filter.conf"
    ] :
      purge => false,
    }
  }

  file { "${nyholm::faster_apache::params::confd_dir}/spdy.conf":
    content => template("${module_name}/apache/mod/spdy/spdy_conf.erb"),
    ensure  => $ensure,
    purge   => false,
    require => Package[$package]
  }

  file { '/usr/local/bin/php-wrapper':
    content => template("${module_name}/apache/mod/spdy/php-wrapper.erb"),
    ensure  => $ensure,
    mode    => 0775,
    purge   => false,
    require => Package[$package]
  }

}
