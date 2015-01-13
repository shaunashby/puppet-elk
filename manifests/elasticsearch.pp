#____________________________________________________________________ 
# File: elasticsearch.pp
#____________________________________________________________________ 
#  
# Author:  <sashby@dfi.ch>
# Created: 2015-01-09 11:06:20+0100
# Revision: $Id$ 
#
# Copyright (C) 2015 
#
#--------------------------------------------------------------------
class elk::elasticsearch() inherits elk::params {

  yumrepo { 'elasticsearch-1.2':
    ensure   => present,
    baseurl  => 'http://packages.elasticsearch.org/elasticsearch/1.2/centos',
    descr    => 'Elasticsearch repository for 1.2.x packages',
    gpgkey   => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
    gpgcheck => 1,
    enabled  => 1,
  }

  class { '::elasticsearch':
    version => "${es_default_version}",
    config  => {
      'cluster.name'                         => "${es_cluster_name}",
      'discovery.zen.ping.multicast.enabled' => false,
    },
  } -> Yumrepo['elasticsearch-1.2']

  elasticsearch::instance { "${es_instance_name}":
    config  => {
      'node.name' => 'DFI Log Aggregator'
    },
    datadir => [ $es_data_dir ],
  }
}
