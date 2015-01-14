# == Class: elk
#
# A class used to manage an ELK stack
#
# === Parameters
#
# Document parameters here.
#
# [*ensure*]
#   Make sure that the stack is running.
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'elk': }
#
# === Authors
#
# Shaun Ashby <sashby@dfi.ch>
#
# === Copyright
#
# Copyright 2014 Shaun ASHBY, DFI Service SA.
#
class elk(
  $ensure          = $elk::params::ensure,
  $enable_webui    = $elk::params::enable_webui,
  $webui_www_root  = $elk::params::webui_www_root,
  ) inherits elk::params {

  # Validate parameters:
  if $ensure in [ 'running', 'stopped' ] {
    $_ensure = 'present'
  } else {
    fail('ensure parameter must be running or stopped')
  }

  class { 'elk::elasticsearch': }

  class { 'elk::logstash':
    ensure                         => $_ensure,
    ssl_receiver                   => true,
    logstash_ssl_listener_hostname => "${fqdn}",
    logstash_es_index_format       => 'dfi-%{+YYYY.MM.dd}',
    logstash_es_cluster_name       => "${elk::params::es_cluster_name}",
    logstash_es_hostname           => "${elk::params::es_host_name}",
    }->Class['elk::elasticsearch']

  if $enable_webui == true {
    class { 'nginx': }
    nginx::resource::vhost { "${::fqdn}":
      www_root => "${webui_www_root}",
    }

    class { 'elk::kibana':
      version  => "${elk::params::kibana_version}",
      src_root => "${webui_www_root}",
    }
  }
}
