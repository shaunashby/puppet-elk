#____________________________________________________________________ 
# File: logstash.pp
#____________________________________________________________________ 
#  
# Author:  <sashby@dfi.ch>
# Created: 2014-12-30 16:04:09+0100
# Revision: $Id$ 
#
# Copyright (C) 2014 
#
#--------------------------------------------------------------------

class elk::logstash(
  $ensure                         = 'running',
  $ssl_enable                     = false,
  $ssl_verify                     = true,
  $ssl_certs_basedir              = '/etc/pki/logstash',
  $logstash_default_version       = '1.4.2-1_2c0f5a1',
  $logstash_listener_hostname     = 'localhost',
  $logstash_ssl_listener_hostname = 'localhost',
  $logstash_es_hostname           = 'localhost',
  $logstash_es_index_format       = 'logstash-%{+YYYY.MM.dd}',
  $logstash_es_cluster_name       = 'LS-test',
  ) {
  $defaults = {
    'LS_USER' => 'root',
    'LS_OPTS' => '"-w 4"'
  }

  if $ensure == 'present' {

    yumrepo { 'logstash-1.4':
      ensure   => present,
      baseurl  => 'http://packages.elasticsearch.org/logstash/1.4/centos',
      descr    => 'Logstash RPM repository at elasticsearch.org',
      gpgkey   => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
      gpgcheck => 1,
      enabled  => 1,
    }

    class { '::logstash':
      ensure        => $ensure,
      init_defaults => $defaults,
      version       => $logstash_default_version,
    } -> Yumrepo['logstash-1.4']

    logstash::configfile { 'syslog-udp-receiver':
      content => template('elk/etc/logstash/conf.d/syslog-udp-receiver.conf.erb'),
      order   => 10,
    }

    if $ssl_enable == true {
      # Set up the SSL certificates:
      file { $ssl_certs_basedir:
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0600',
      }

      file { "${ssl_certs_basedir}/certs":
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        require => File[$ssl_certs_basedir],
      }

      file { "${ssl_certs_basedir}/private":
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        require => File[$ssl_certs_basedir],
      }

      $logstash_ssl_listener_ca_cert = '/etc/pki/logstash/certs/ca.pem'

      file { $logstash_ssl_listener_ca_cert:
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0640',
        source  => 'puppet:///modules/elk/etc/pki/tls/certs/ca.pem',
        require => File["${ssl_certs_basedir}/certs"],
      }

      $logstash_ssl_listener_host_cert = "/etc/pki/logstash/certs/${logstash_ssl_listener_hostname}.cert.pem"

      file { $logstash_ssl_listener_host_cert:
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0640',
        source  => "puppet:///modules/elk/etc/pki/tls/certs/${logstash_ssl_listener_hostname}.cert.pem",
        require => File["${ssl_certs_basedir}/certs"],
      }

      $logstash_ssl_listener_host_key  = "/etc/pki/logstash/private/${logstash_ssl_listener_hostname}.key.pem"

      file { $logstash_ssl_listener_host_key:
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0400',
        source  => "puppet:///modules/elk/etc/pki/tls/private/${logstash_ssl_listener_hostname}.key.pem",
        require => File["${ssl_certs_basedir}/private"],
      }

      logstash::configfile { 'syslog-tcp-ssl-receiver':
        content => template('elk/etc/logstash/conf.d/syslog-tcp-ssl-receiver.conf.erb'),
        order   => 20,
        } -> File[$logstash_ssl_listener_host_cert]
    } else {
      logstash::configfile { 'syslog-tcp-receiver':
        content => template('elk/etc/logstash/conf.d/syslog-tcp-receiver.conf.erb'),
        order   => 20,
      }
    }

    logstash::configfile { 'syslog-timestamp-filter':
      source => 'puppet:///modules/elk/etc/logstash/conf.d/syslog-timestamp-filter.conf',
      order  => 40,
    }

    logstash::configfile { 'output-elasticsearch':
      content => template('elk/etc/logstash/conf.d/output-elasticsearch.conf.erb'),
      order   => 60,
    }
  }

}
