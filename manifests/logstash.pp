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
      source => 'puppet:///modules/elk/etc/logstash/conf.d/syslog-udp-receiver.conf',
      order  => 10,
    }

    if $ssl_receiver == true {
      logstash::configfile { 'syslog-tcp-ssl-receiver':
        source => 'puppet:///modules/elk/etc/logstash/conf.d/syslog-tcp-ssl-receiver.conf',
        order  => 20,
      }
    }

    logstash::configfile { 'output-elasticsearch':
      source => 'puppet:///modules/elk/etc/logstash/conf.d/output-elasticsearch.conf',
      order  => 30,
    }
  }

}
