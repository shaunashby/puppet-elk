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

class elk::logstash {
  $defaults = {
    'LS_USER' => 'root',
    'LS_OPTS' => '-w 4'
  }

  class { '::logstash':
    init_defaults => $defaults,
    package_url   => "https://download.elasticsearch.org/logstash/logstash/packages/centos/logstash-1.4.2-1_2c0f5a1.noarch.rpm",
  }

  logstash::configfile { 'local-input':
    source => 'puppet:///etc/logstash/conf.d/local-input.conf',
    order  => 10,
  }

  logstash::configfile { 'syslog-udp-receiver':
    source => 'puppet:///etc/logstash/conf.d/syslog-udp-receiver.conf',
    order  => 20,
  }

  logstash::configfile { 'syslog-tcp-ssl-receiver':
    source => 'puppet:///etc/logstash/conf.d/syslog-tcp-ssl-receiver.conf',
    order  => 30,
  }

  logstash::configfile { 'output-elasticsearch':
    source => 'puppet:///etc/logstash/conf.d/output-elasticsearch.conf',
    order  => 40,
  }

}
