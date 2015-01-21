# == Class: elk
#
# A class used to manage an ELK stack
#
# === Parameters
#
# Document parameters here.
#
# [*ensure*]
#   Make sure that logstash and Elasticsearch are configured and running.
#
# [*enable_webui*]
#   Configure the web interface (Kibana3).
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*webui_www_root*]
#   When the parameter enable_webgui is set, pass the root of the Kibana
#   installation using this variable.
# [* ssl_receiver *]
#   Enable the SSL listener in logstash, rather than plain TCP.
# [* logstash_ssl_listener_hostname *]
#   The name of the host where the logstash receiver is listening.
# [* logstash_es_index_format *]
#   The naming format for indices created automatically by Elasticsearch.
# [* logstash_es_cluster_name *]
#   The name of the Elasticsearch cluster.
# [* logstash_es_hostname *]
#   The host name of the Elasticsearch server.
# [* kibana_dashboard_name *]
#   The name of the dashboard to present as default from the landing page.
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
    ssl_enable                     => true,
    logstash_ssl_listener_hostname => $::fqdn,
    logstash_es_index_format       => 'dfi-%{+YYYY.MM.dd}',
    logstash_es_cluster_name       => $elk::params::es_cluster_name,
    logstash_es_hostname           => $elk::params::es_host_name,
    }->Class['elk::elasticsearch']

  if $enable_webui == true {
    class { 'nginx': }

    file { '/etc/nginx/conf.d/auth':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }

    file { '/etc/nginx/conf.d/auth/elk.htpasswd':
      ensure  => present,
      path    => '/etc/nginx/conf.d/auth/elk.htpasswd',
      content => 'admin:{SHA}5dYSM8im55ejohUfCeS7vJNCvCk=',
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      require => File['/etc/nginx/conf.d/auth'],
    }

    nginx::resource::vhost { $::fqdn:
      ensure               => present,
      www_root             => $webui_www_root,
      auth_basic           => 'DFI Kibana Web',
      auth_basic_user_file => '/etc/nginx/conf.d/auth/elk.htpasswd',
      listen_port          => 80,
    }

    class { 'elk::kibana':
      version               => $elk::params::kibana_version,
      src_root              => $webui_www_root,
      kibana_dashboard_name => 'DFI',
    }
  }
}
