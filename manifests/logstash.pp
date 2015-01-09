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
  $ssl_receiver                   = false,
  $ssl_enable                     = false,
  $ssl_verify                     = true,
  $logstash_listener_hostname     = 'localhost',
  $logstash_ssl_listener_hostname = 'localhost',
  $logstash_es_listener_hostname  = 'localhost',
  ) {
  $defaults = {
    'LS_USER' => 'root',
    'LS_OPTS' => '"-w 4"'
  }

  if $ensure == 'present' {
    class { '::logstash':
      init_defaults   => $defaults,
      ensure          => $ensure,
    }

    logstash::configfile { 'syslog-udp-receiver':
      content => template('elk/etc/logstash/conf.d/syslog-udp-receiver.conf.erb'),
      order   => 10,
    }

    if $ssl_receiver == true {
      # Set up the SSL certificates:
      $logstash_ssl_listener_ca_cert   = "/etc/pki/logstash/ca.pem"
      $logstash_ssl_listener_host_cert = "/etc/pki/logstash/${logstash_ssl_listener_hostname}.cert.pem"
      $logstash_ssl_listener_host_key  = "/etc/pki/logstash/${logstash_ssl_listener_hostname}.key.pem"

      logstash::configfile { 'syslog-tcp-ssl-receiver':
        content => template('elk/etc/logstash/conf.d/syslog-tcp-ssl-receiver.conf.erb'),
        order  => 20,
      }
    }

    logstash::configfile { 'syslog-timestamp-filter':
      source => 'puppet:///modules/elk/etc/logstash/conf.d/syslog-timestamp-filter.conf',
      order   => 40,
    }

    logstash::configfile { 'output-elasticsearch':
      content => template('elk/etc/logstash/conf.d/output-elasticsearch.conf.erb'),
      order  => 60,
    }
  }

}
